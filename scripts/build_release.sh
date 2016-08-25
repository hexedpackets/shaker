#!/usr/bin/env bash

docker run --rm -v `pwd`:/opt/shaker --workdir /opt/shaker trenpixster/elixir:1.2.5 scripts/exrm.sh
