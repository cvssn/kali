#!/usr/bin/perl

eval ("use IO::Socket;");die "[error] IO::Socket módulo perl não está instalado \n" if $@;
eval ("use sigtrap;");die "[error] sigtrap perl não é suportado \n" if $@;
eval ("use Net::hostent;");die "[error] Net::hostent módulo perl não está instalado \n" if $@;
eval ("use Getopt::Std;");die "[error] Getopt::Std módulo perl não está instalado \n" if $@;
eval ("use Net::Telnet;");die "[error] Net::Telnet módulo perl não está instalado \n" if $@;
eval ("use Net::SSH::Perl;");die "[error] Net::SSH::Perl módulo perl não está instalado \n" if $@;
eval ("use Net::SSLeay qw(get_https post_https sslcat make_headers make_form);");die "[error] Net::SSLeay módulo perl não está instalado \n" if $@;
eval ("use MIME::Base64 qw(encode_base64);");die "[error] MIME::Base64 módulo perl não está instalado \n" if $@;
eval ("use Net::SNMP;");die "[error] Net::SNMP módulo perl não está instalado \n" if $@;
eval ("use POSIX;");die "[error] POSIX perl não é suportado \n" if $@;


eval{require "torch.conf"};

if($@) {
    print "falha ao carregar a configuração file:torch.conf\n";
}

print "utilizando arquivo de configuração torch.conf...\n";


# plugins
print "carregando include e plugin...\n";

opendir(DIR, "include");

while($in=readdir(DIR)) {
    next if ($in=~/^[.]{1,2}/);
    next if !($in=~/\.pm$/);

    require "include/$in";
}

closedir(DIR);


my $version = "0.4b";

# staff de snmp
$ENV{'MIBS'}="ALL"; # carregar todos os mibs disponíveis

&getopts('AtsdunbcjzwVl:XF:O:g');

use vars qw(
    $opt_A
    $opt_t
    $opt_s
    $opt_d
    $opt_c
    $opt_u
    $opt_n
    $opt_V
    $opt_l
    $opt_w
    $opt_z
    $opt_a
    $opt_X
    $opt_F
    $opt_O
    $opt_b
    $opt_j
    $opt_g
);

if ( !$opt_F ) { $host = $ARGV[0]; }
else { chomp $opt_F; $targetfile = $opt_F }

if ($opt_V)
{
    print("versão $version\n");

    exit(0);
}

if (
    ( !$host && !$opt_F ) || ( $host && $opt_F ) || (
        !$opt_A
		&& !$opt_t
		&& !$opt_s
		&& !$opt_w
		&& !$opt_z
		&& !$opt_X
		&& !$opt_F
		&& !$opt_u
		&& !$opt_n
		&& !$opt_b
		&& !$opt_c
		&& !$opt_j
		&& !$opt_g
		&& !$ARGV[1]
    )
)
{
    $usage;

    exit(0);
}

if ( $opt_g && !($opt_u ||  $opt_j ) )
{
    print("-g só deve ser usado com -u ou -j com a opção -b\n");

    exit(0);
}

if ( $opt_g && ($opt_u ) )
{
    print("você deve ser root ou administrador para iniciar o servidor tftp! \n necessário para download de configuração por snmp\n");
}


if ( $opt_b && !($opt_t || $opt_s || $opt_u || $opt_c || $opt_w || $opt_j ) )
{
    print("-b só deve ser usado com a opção -t , -s, -c , -j , -w ou -u\n");

    exit(0);
}

$logfile = $opt_0 if $opt_0;

print("\n");

&banner;

if ($opt_l)
{
    if ( ( $opt_l !~ /^[cdv]+$/ ) )
    {
        print "definição loglevel desconhecida: " . $opt_l . "\n";

        exit(0);
    }

    $llevel = $opt_l;
}

if ($opt_F)
{
    $date = `date`;

    open( TARGETLIST, "$targetfile" ) || die "$0: não foi possível ler de $targetfile! ($!)";

    while (<TARGETLIST>) { chomp; push( @targetlist, $_ ); }
} else
{
    if ( $host =~ /[A-z]/ )
    {
        @targetlist=($host);
    } else
    {
        &GetRange;
    }
}

$tgt_cnt = defined $IPstart ? $IPend-$IPstart : $#targetlist + 1;

log_print("a lista de alvos contém host(s) $tgt_cnt\n", "c");

# determina quantos processos de scanner são necessários

$proc_cnt = $tgt_cnt / $hosts_per_process > $max_processes ? $max_processes : floor($tgt_cnt / $hosts_per_process);
$proc_tgt_cnt = ceil( $tgt_cnt / ($proc_cnt + 1) );

log_print("irá bifurcar processos adicionais do scanner $proc_cnt\n", "c") if $proc_cnt;

# processos de scanner de garfo

@children = ();

for ($bi = 0, $pid = -1 ; $bi < $tgt_cnt - $proc_tgt_cnt; $bi += $proc_tgt_cnt)
{
    last if !($pid = fork());

    push(@children, $pid);
}

# determina o intervalo de varredura para cada processo

$ei = $bi + $proc_tgt_cnt <= $tgt_cnt ? $bi + $proc_tgt_cnt - 1 : $tgt_cnt - 1;

if (defined $IPstart)
{
    $start = GetIP($IPstart + $bi);
	$end = GetIP($IPstart + $ei);
}
else
{
    $start = $targetlist[$bi];
	$end = $targetlist[$ei];

	@targetlist = @targetlist[$bi..$ei];
}


# performa o scan

log_print("varredura de intervalo de $start a $end\n", "c") unless ("$start" eq "$end")

for ($c = $bi; $c <= $ei; $c++)
{
    $host = defined $IPstart ? GetIP($IPstart + $c) : $targetlist[$c - $bi];

	log_print( "$$:\tchecando $host ...\n", "c" );
	log_start();

	&scanit;

	log_write("host: $host *****************************************************\n");
}

if ($pid) # processo master
{
    {} until wait() == -1; # aguardar pelo children para terminar

    &endbanner;

    push (@children, $$);

    foreach $cpid (@children)
    {
        `cat $tmplogprefix.$cpid >>$logfile && rm -f $tmplogprefix.$cpid` if (stat("$tmplogprefix.$cpid"))
    }
}

###############
# sub-rotinas #
###############
sub scanit
{
    if ( !&check_ip($host) )
    {
        log_print("tentando resolver o nome do host $host\n\n", "c");

        my $handler = gethost($host);

        if (!$handler)
        {
            log_print("$host não resolve, morri\n\n", "c");

            exit(0);
        }

        $target = inet_ntoa( @{ $handler->addr_list }[0] );

        log_print("host resolvido para: $target\n\n", "i");

        $host_resolves = 1;
    } else
    {
        $target        = $host;
		$host_resolves = 0;
    }

    if ($opt_A)
    {
        $opt_u = "1";
		$opt_n = "1";
		$opt_t = "1";
		$opt_w = "1";
		$opt_s = "1";
		$opt_c = "1";
		$opt_j = "1";
    }

    if ($opt_t)
    {
        if (telnetfprint())
        {
            telnet_leak_user() ? pwdbforce() : bruteforce(0) if $opt_b;
        }
    }

    if ($opt_s)
    {
        if (sshfprint())
        {
            bruteforce(1) if $opt_b;
        }
    }

    if ($opt_u)
	{
	    if ( snmp_ping()) 
	    {
	        snmp_bruteforce(1) if $opt_b;    
	    }
	}

    if ($opt_n)
	{
	    &ntp
	}

	if ($opt_j)
	{
	    &tftp
	}

	if ($opt_z)
	{
        &cisco_auth_http
    }

    if ($opt_w)
	{
		if (checkweb())
		{
	        brute_www(1) if $opt_b;
	    }
    }

    if ($opt_c)
	{
		if (ssl_finger())
		{
	        brute_ssl(1) if $opt_b;
	    }
    }
}