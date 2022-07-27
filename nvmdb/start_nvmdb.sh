#!/bin/bash

coproc ./nvmdb
#echo out = ${COPROC[0]}, in = ${COPROC[1]}

while true; do
    read -u ${COPROC[0]} CMD REST
    echo $0 got: $CMD \"$REST\" >/dev/stderr

    case $CMD in
	find)
	    echo "find FOUND" >&${COPROC[1]}
	    ;;
	insert)
	    echo "insert OK" >&${COPROC[1]}
	    ;;
	*)
	    echo "Unknown CMD = $CMD" >/dev/stderr
	    exit 1
	    ;;
    esac
done
