#!/bin/bash

openssldir="/etc/openssl"

useopenssl11="no"

opensslver="1.0.2"
opensslrel="i"

if [ $useopenssl11 = "yes" ]; then
    opensslver="1.1.0"
    opensslrel="f"
fi

name="openssl-${opensslver}${opensslrel}"
archive="$name.tar.gz"

url="https://www.openssl.org/source/old/$opensslver/$archive"

builddir=`mktemp -d`

curdir=`pwd`

pushd $builddir

curl -0 $url

if [ $? -ne 0 ]; then
    rm -rf $builddir
    
    exit
fi

tar -xzf $archive

pushd $name

./config enable-ssl2 enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers enable-shared --prefix=/usr --openssldir=$openssldir
make depend
make

if [ $useopenssl11 = "yes" ]; then
    cp -a libcrypto.so{,.1.1} $curdir
    cp -a libssl.so{,.1.1} $curdir
else
    cp -a libcrypto.so{,.1.0.0} $curdir
    cp -a libssl.so{,.1.0.0} $curdir
fi

cp -a apps/openssl $curdir

popd
popd

# fazer todas as distros
if [ $useopenssl11 = "yes" ]; then
    ln -sf libssl.so{.1.1,.11}
    ln -sf libcrypto.so{.1.1,.11}
else
    ln -sf libssl.so{.1.0.0,.10}
    ln -sf libcrypto.so{.1.0.0,.10}
    ln -sf libssl.so{.1.0.0,.1.0.2}
    ln -sf libcrypto.so{.1.0.0,.1.0.2}
fi

rm -rf $builddir