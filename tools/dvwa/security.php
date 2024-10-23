<?php

define( 'DVWA_WEB_PAGE_TO_ROOT', '' );
require_once DVWA_WEB_PAGE_TO_ROOT . 'dvwa/includes/dvwaPage.inc.php';

dvwaPageStartup( array('authenticated') );

$page = dvwaPageNewGrab();
$page[ 'title' ]   = 'segurança dvwa' . $page[ 'title_separator' ].$page[ 'title' ];
$page[ 'page_id' ] = 'security';

$securityHtml = '';

if( isset( $_POST['seclev_submit'] ) ) {
    // anti-csrf
    checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'security.php' );

    $securityLevel = '';

    switch( $_POST[ 'security' ] ) {
        case 'low':
            $securityLevel = 'low';
            break;

        case 'medium':
            $securityLevel = 'medium';
            break;

        case 'high':
                $securityLevel = 'high';
                break;

        default:
            $securityLevel = 'impossible';
            break;
    }

    dvwaSecurityLevelSet( $securityLevel );
    dvwaMessagePush( "level de segurança definido para {$securityLevel}" );
    dvwaPageReload();
}

$securityOptionsHtml = '';
$securityLevelHtml   = '';

foreach( array( 'low', 'medium', 'high', 'impossible' ) as $securityLevel ) {
    $selected = '';

    if( $securityLevel == dvwaSecurityLevelGet() ) {
        $selected = ' selected="selected"';
        $securityLevelHtml = "<p>level de segurança atual é: <em>$securityLevel</em>.</p>";
    }

    $securityOptionsHtml .= "<option value=\"{$securityLevel}\"{$selected}>" . ucfirst($securityLevel) . "</option>";
}

// anti-csrf
generateSessionToken();

$page[ 'body' ] .= "
<div class=\"body_padded\">
	<h1>DVWA Security <img src=\"" . DVWA_WEB_PAGE_TO_ROOT . "dvwa/images/lock.png\" /></h1>
	
    <br>

	<h2>level de segurança</h2>

	{$securityHtml}

	<form action=\"#\" method=\"POST\">
		{$securityLevelHtml}
		<p>você pode definir o nível de segurança como baixo, médio, alto ou impossível. o nível de segurança altera o nível de vulnerabilidade do dvwa:</p>
		
        <ol>
			<li> baixo - This security level is completely vulnerable and <em>has no security measures at all</em>. It's use is to be as an example of how web application vulnerabilities manifest through bad coding practices and to serve as a platform to teach or learn basic exploitation techniques.</li>
			<li> médio - This setting is mainly to give an example to the user of <em>bad security practices</em>, where the developer has tried but failed to secure an application. It also acts as a challenge to users to refine their exploitation techniques.</li>
			<li> alto - This option is an extension to the medium difficulty, with a mixture of <em>harder or alternative bad practices</em> to attempt to secure the code. The vulnerability may not allow the same extent of the exploitation, similar in various Capture The Flags (CTFs) competitions.</li>
			<li> impossível - This level should be <em>secure against all vulnerabilities</em>. It is used to compare the vulnerable source code to the secure source code.<br>Prior to DVWA v1.9, this level was known as 'high'.</li>
		</ol>

		<select name=\"security\">
			{$securityOptionsHtml}
		</select>

		<input type=\"submit\" value=\"Submit\" name=\"seclev_submit\">
		" . tokenField() . "
	</form>
</div>";

dvwaHtmlEcho( $page );

?>