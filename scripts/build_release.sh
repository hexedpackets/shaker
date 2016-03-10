#!/usr/bin/env bash

docker run --rm -v `pwd`:/opt/shaker --workdir /opt/shaker trenpixster/elixir scripts/exrm.sh
