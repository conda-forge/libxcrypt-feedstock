#!/bin/bash
set -eu

make clean || true
export CFLAGS="${CFLAGS} -Wno-error"
if [[ "${PERL:-}" = "$PREFIX"* ]]; then
    export PERL=$BUILD_PREFIX/bin/perl
fi

if [[ "${PKG_NAME}" == "libxcrypt" ]]; then
    export OBSOLETE_API="no"
else
    export OBSOLETE_API="glibc"
fi

./configure \
    --prefix="${PREFIX}" \
    --disable-static \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api="${OBSOLETE_API}" \
    --disable-failure-tokens

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION-0}" != "1" ]]; then
  make check
fi

if [[ "${OBSOLETE_API}" == "glibc" ]]; then
    install -c .libs/libcrypt.so.1.* "$PREFIX/lib/"
    (cd "$PREFIX/lib" && ln -s -f libcrypt.so.1.* libcrypt.so.1)
else
    make install -j${CPU_COUNT}
fi
