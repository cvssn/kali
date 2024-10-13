#!/bin/sh

# testar o comando afsegment

export PATH=$srcdir:../tools:../../tools:.:$PATH

BLANK_BASE=`mktemp -t blankXXXXX`
BLANK_RAW=$BLANK_BASE.raw
BLANK_AFF=$BLANK_BASE.aff

unset AFFLIB_PASSPHRASE

echo === colocando um novo segmento de metadados em blank.aff ===

/bin/rm -f $BLANK_AFF

cp /dev/null $BLANK_RAW

affcopy $BLANK_RAW $BLANK_AFF
affsegment -ssegname=testseg1 $BLANK_AFF

if [ x"testseg1" = x`affsegment -p segname $BLANK_AFF` ] ; then
    echo affsegment funcionou
else
    echo affsegment não funcionou apropriadamente
    
    exit 1
fi

/bin/rm -f $BLANK_RAW $BLANK_AFF