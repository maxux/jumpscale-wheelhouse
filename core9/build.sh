#!/bin/bash
set -ex

export branch="development"
export openssl="openssl-1.0.2o"
export target="core9"

pushd /tmp

wget ftp://ftp.openssl.org/source/${openssl}.tar.gz
tar -xzf ${openssl}.tar.gz

pushd ${openssl}
./config --prefix=/usr --openssldir=/usr/openssl threads shared
make -j 5
make install_sw
popd

# cleaning existing wheelhouse
rm -rf /io/wheelhouse/repository/*


git clone https://github.com/pyca/cryptography

pushd cryptography
git checkout 2.2

for pybin in $(ls -1d /opt/python/*{35,36}*/bin | grep -v cpython); do
    "${pybin}/pip" wheel --no-deps . -w /io/wheelhouse/repository/
done
popd


git clone -b ${branch} https://github.com/jumpscale/${target}
pushd ${target}

# extract install_require from setup.py
sed -n '/install_require/,/\],/p;/\],/q' setup.py > requirements.txt

# remove first and last lines
sed -i '1,1d' requirements.txt
sed -i '$ d' requirements.txt

# clean python syntax
sed -i "s/ //g;s/'//g;s/,//g" requirements.txt

for pybin in $(ls -1d /opt/python/*{35,36}*/bin | grep -v cpython); do
    "${pybin}/pip" install -r requirements.txt
    "${pybin}/pip" freeze > /tmp/full-requirements.txt
    "${pybin}/pip" wheel -r /tmp/full-requirements.txt -w /io/wheelhouse/repository/
done

for whl in /io/wheelhouse/repository/*.whl; do
    if [[ $whl = *"none-any"* ]]; then continue; fi

    auditwheel repair "$whl" -w /io/wheelhouse/repository/
done

popd
popd

# release archives
pushd /io/wheelhouse/repository

rm -rf /io/wheelhouse/release

for version in cp35 cp36; do
    endpoint="/io/wheelhouse/release/${version}"
    mkdir -p ${endpoint}
    rm -rf ${endpoint}/*

    cp -av *none-any* ${endpoint}/
    cp -av *${version}* ${endpoint}/

    tar -czf /io/wheelhouse/release/jumpscale-${target}-${version}.tar.gz -C ${endpoint} .
done

ls -alh /io/wheelhouse/release/
popd
