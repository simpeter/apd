#!/bin/bash

coproc ./nvmdb
# echo out = ${COPROC[0]}, in = ${COPROC[1]} >/dev/stderr

# Below is a test backend, which you will replace with your own code
# You can attach any binary with:
#exec ./example <&${COPROC[0]} >&${COPROC[1]}

while true; do
    read -u ${COPROC[0]} CMD REST
    echo $0 got: $CMD \"$REST\" >/dev/stderr

    case $CMD in
	find)
	    # echo "$0: sending 'find FOUND' to ${COPROC[1]}" >&2
	    echo "find FOUND" >&${COPROC[1]}
	    ;;
	insert)
	    # echo "$0: sending 'insert OK' to ${COPROC[1]}" >&2
	    echo "insert OK" >&${COPROC[1]}
	    ;;
	*)
	    echo "$0: Unknown CMD = $CMD" >/dev/stderr
	    exit 1
	    ;;
    esac
done
