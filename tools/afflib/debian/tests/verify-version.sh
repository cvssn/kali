#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

affcat -v 2> /dev/null
affcompare -V 2> /dev/null
affconvert -V 2> /dev/null
affcopy -V 2> /dev/null
affcrypto -V 2> /dev/null
affdiskprint -V 2> /dev/null
affinfo -V 2> /dev/null
affix -v 2> /dev/null
affrecover -v 2> /dev/null
affsegment -V 2> /dev/null
affsign -v 2> /dev/null
affstats -V 2> /dev/null
affverify -V 2> /dev/null
affxml -V 2> /dev/null

# affuse não possui a opção -v ou -V