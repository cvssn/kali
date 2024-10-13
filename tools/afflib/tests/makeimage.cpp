/*
 * makeimage.cpp:
 *
 * cria uma imagem com um número fornecido dos setores
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <err.h>

const char *progname = "makeimage";

void usage()
{
    errx(1, "uso: %s arquivo blockcount\n", progname);
}

int main(int argc, char **argv)
{
    if (argc != 3) usage();

    int  count = atoi(argv[2]);
    char buf[512];

    FILE *out = fopen(argv[1], "wb");
    if (!out) err(1, "fopen(%s)", argv[1]);

    memset(buf, ' ', sizeof(buf));

    buf[511] = '\000';

    for (int i = 0; i < count; i++) {
        sprintf(buf, "block %d\n", i);
        
	    fwrite(buf, sizeof(buf), 1, out);
    }

    fclose(out);
}