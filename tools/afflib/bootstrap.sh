#!/bin/sh

echo script bootstrap para criar script de configuração utilizando o autoconf
echo

# utilizar os instalados primeiro, não importando o que o path dizer
export PATH=/usr/bin:/usr/sbin:/bin:$PATH
touch NEWS README AUTHORS Changelog stamp-h
aclocal
LIBTOOLIZE=glibtoolize
if test `which libtoolize`x != "x" ; 
    then LIBTOOLIZE=libtoolize 
fi
$LIBTOOLIZE  -f
autoheader -f
autoconf -f
automake --add-missing -c
echo "pronto para iniciar a configuração!"
if [ $1"x" != "x" ]; then
    ./configure "$@"
fi