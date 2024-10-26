#!/bin/sh

set -e

amass enum --nocolor -d megacorpone.com | LC_ALL=C sort -n > generated_output

# verifica se as informações principais estão na saída
for name in $(cat debian/tests/static_output); do
    grep $name generated_output;
done

exit $?