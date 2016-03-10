#!/usr/bin/env bash

export MIX_ENV=prod

mix deps.clean --all
rm -rf rel/

mix deps.get
mix deps.compile
mix compile
mix release

VERSION=`cat VERSION | xargs`
mv -v rel/shaker/releases/${VERSION}/shaker.tar.gz shaker-${VERSION}.tar.gz
