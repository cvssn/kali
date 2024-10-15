#include <sys/types.h>
#include <string.h>
#include "compat-bsd.h"

/*
 * acrescenta src à string dst de tamanho dsize (ao contrário de strncat, dsize é o
 * tamanho total do dst, sem espaço restante).
 */
size_t
strlcat(char *dst, const char *src, size_t dsize)
{
    const char *odst = dst;
	const char *osrc = src;
    
	size_t n = dsize;
	size_t dlen;

    /* encontre o final do dst e ajuste os bytes restantes, mas não ultrapasse o final */
    while (n-- != 0 && *dst != '\0')
		dst++;

	dlen = dst - odst;
	n = dsize - dlen;

    if (n-- == 0)
		return(dlen + strlen(src));

	while (*src != '\0') {
		if (n != 0) {
			*dst++ = *src;

			n--;
		}

		src++;
	}

	*dst = '\0';

    return(dlen + (src - osrc)); /* contagem não inclui nul */
}