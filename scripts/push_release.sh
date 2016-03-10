#!/usr/bin/env bash

VERSION=`cat VERSION | xargs`
git tag v${VERSION} && git push --tags && \
github-release release \
    --user hexedpackets \
    --repo shaker \
    --tag v$VERSION \
    --name "v$VERSION" \
    --description "v$VERSION" && \
github-release upload \
    --user hexedpackets \
    --repo shaker \
    --tag v$VERSION \
    --name "linux-amd64-shaker-release.tar.gz" \
    --file shaker-${VERSION}.tar.gz
