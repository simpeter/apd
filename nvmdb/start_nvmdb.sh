#!/bin/bash

coproc ./nvmdb

echo out = $COPROC[0], in = $COPROC[1]

while true; do
    read
    echo $0 got: \"$REPLY\" >/dev/stderr
    echo "find FOUND"
done
