#include "config.h"

#ifdef HAVE_WOLFSSL
#include <wolfssl/options.h>
#include <wolfssl/wolfcrypt/settings.h>
#include <wolfssl/openssl/ssl.h>
#include <wolfssl/openssl/x509v3.h>
#else
#include <openssl/ssl.h>
#include <openssl/x509v3.h>
#endif

#include "compat-ssl.h"

const unsigned char *
ASN1_STRING_get0_data(const ASN1_STRING *x)
{
	return ASN1_STRING_data((ASN1_STRING *)x);
}