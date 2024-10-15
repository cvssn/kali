#include <sys/types.h>
#include <string.h>
#include "compat-bsd.h"

size_t
strlcpy(char *dst, const char *src, size_t dsize)
{
	const char *osrc = src;
	size_t nleft = dsize;

	/* copia quantos bytes couberem */
	if (nleft != 0) {
		while (--nleft != 0) {
			if ((*dst++ = *src++) == '\0')
				break;
		}
	}

	/* não há espaço suficiente em dst, adicione nul e percorra o resto do src */
	if (nleft == 0) {
		if (dsize != 0)
			*dst = '\0'; /* dst com terminação nul */

		while (*src++)
			;
	}

	return(src - osrc - 1);	/* contagem não inclui nul */
}