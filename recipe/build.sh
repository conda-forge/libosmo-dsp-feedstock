#!/usr/bin/env bash

set -ex

autoreconf_args=(
  --force
  --install
  --verbose
)

configure_args=(
  --prefix=$PREFIX
)

if [[ "$target_platform" == win-64 ]]; then
  # set default include and library dirs for Windows build
  export CPPFLAGS="$CPPFLAGS -isystem $PREFIX/include"
  export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
  # to pick up pkg-config macros from m2-pkg-config
  autoreconf_args+=(
    -I "$BUILD_PREFIX/Library/usr/share/aclocal"
  )
  # so we can make shared libs without overzealous checking
  export lt_cv_deplibs_check_method=pass_all
fi

autoreconf "${autoreconf_args[@]}"
./configure "${configure_args[@]}" || cat config.log
make V=1 -j${CPU_COUNT}
make install

# remove static library
rm $PREFIX/lib/libosmodsp.a*
