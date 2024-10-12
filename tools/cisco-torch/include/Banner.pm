sub usage
{
    print("versão $version\nuso: ./cisco-torch.pl <options> <IP,hostname,network>\n\n");
	print("ou: ./cisco-torch.pl <options> -F <hostlist>\n\n");
	print("opções disponíveis:\n");
	print("-O <output file>\n");
	print("-A\t\ttodos os tipos de digitalização de impressões digitais combinados\n");
	print("-t\t\tvarredura cisco telnetd\n");
	print("-s\t\tvarredura cisco sshd\n");
	print("-u\t\tvarredura cisco snmp\n");
	print("-g\t\tconfiguração cisco ou download de arquivo tftp\n");
	print("-n\t\tverificação de impressão digital ntp\n");
	print("-j\t\tverificação de impressão digital tftp\n");
	print("-l <type>\tloglevel\n");
	print("\t\tc  critical (default)\n");
	print("\t\tv  verbose\n");
	print("\t\td  debug\n");
	print("-w\t\tverificação do servidor web cisco\n");
	print("-z\t\tverificação de vulnerabilidade de autorização http do cisco ios\n");
	print("-c\t\tservidor web cisco com verificação de suporte ssl\n");
	print("-b\t\tataque de dicionário de senha (utilizar com -s, -u, -c, -w , -j ou -t apenas)\n");
	print("-V\t\timprimir versão da ferramenta e sair\n");
	print("examplos:\t./cisco-torch.pl -A 10.10.0.0\/16\n");
	print("\t\t./cisco-torch.pl -s -b -F sshtocheck.txt\n");
    print("\t\t./cisco-torch.pl -w -z 10.10.0.0\/16\n");
	print("\t\t./cisco-torch.pl -j -b -g -F tftptocheck.txt\n");
}

sub banner
{
    log_print("###############################################################\n", "c");
	log_print("#   scanner cisco torch mass   $version                       #\n", "c");
    log_print("#   porque precisamos disso...                                #\n", "c");
	log_print("#   https://www.arhont.com/cisco-torch.pl                     #\n", "c");
	log_print("###############################################################\n", "c");

	log_print( "\n", "c" );
}

sub banner_end
{
    log_print("###############################################################\n", "c");
	log_print("#   scanner cisco torch mass   $version                       #\n", "c");
    log_print("#   toda a varredura foi feita                                #\n", "c");
	log_print("#   https://www.arhont.com/cisco-torch.pl                     #\n", "c");
	log_print("###############################################################\n", "c");
    
	log_print( "\n", "c" );
}

1;