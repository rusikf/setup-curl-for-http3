#!/bin/bash

set -e
BUILD_DIR="/home/deploy/curl_7_71_for_http3/build"
DIR1="$BUILD_DIR/openssl"
DIR2="$BUILD_DIR/nghttp3"
DIR3="$BUILD_DIR/ngtcp2"
mkdir $BUILD_DIR

echo "Setup openssl"
git clone --depth 1 -b OpenSSL_1_1_1d-quic-draft-27 https://github.com/tatsuhiro-t/openssl
cd openssl
./config enable-tls1_3 --prefix=$DIR1
make
make install_sw

echo 'Setup nghttp3'
cd ..
git clone https://github.com/ngtcp2/nghttp3
cd nghttp3
autoreconf -i
./configure --prefix=$DIR2 --enable-lib-only
make
make install

echo 'Setup ngtcp2'
cd ..
git clone https://github.com/ngtcp2/ngtcp2
cd ngtcp2
autoreconf -i
./configure PKG_CONFIG_PATH=$DIR1/lib/pkgconfig:$DIR2/lib/pkgconfig LDFLAGS="-Wl,-rpath,$DIR1/lib" --prefix=$DIR3
make
make install

echo 'Setup Curl'
cd ..
git clone https://github.com/curl/curl
cd curl
./buildconf 
LDFLAGS="-Wl,-rpath,$DIR1/lib" ./configure --with-ssl=$DIR1 --with-nghttp3=$DIR2 --with-ngtcp2=$DIR3 --enable-alt-svc
make

echo 'Success'

