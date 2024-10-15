#define _ISOC99_SOURCE

#include "config.h"

#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>

#include "axel.h"


/**
 * buffer abstrato
 *
 * @returns 0 caso ok, um valor negativo para erros
 */
int
abuf_setup(abuf_t *abuf, size_t len)
{
    char *p;

    if (len) {
        p = realloc(abuf->p, len);

        if (!p)
            return -ENOMEM;
    } else {
        free(abuf->p);

        p = NULL;
    }

    abuf->p = p;
    abuf->len = len;

    return 0;
}

int
abuf_printf(abuf_t *abuf, const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);

    for (;;) {
        size_t len = vsnprintf(abuf->p, abuf->len, fmt, ap);

        if (len < abuf->len)
            break;

        int r = abuf_setup(abuf, len + 1);

        if (r < 0)
            return r;
    }

    va_end(ap);

    return 0;
}

/**
 * concatenação de string. o buffer deve conter uma string c válida
 *
 * @returns 0 caso ok, ou um valor negativo para erro
 */
int
abuf_strcat(abuf_t *abuf, const char *src)
{
    size_t nread = strlcat(abuf->p, src, abuf->len);

    if (nread > abuf->len) {
        size_t done = abuf->len - 1;

        int ret = abuf_setup(abuf, nread);

        if (ret < 0)
            return ret;

        memcpy(abuf->p + done, src + done, nread - done);
    }

    return 0;
}