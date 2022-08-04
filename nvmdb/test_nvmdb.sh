#!/bin/bash

DB_BINARY=./example

# Replace ./example, below, with the binary name of your database backend
coproc $DB_BINARY
echo out = ${COPROC[0]}, in = ${COPROC[1]} >/dev/stderr

RECS=0

while true; do
    HOTELID=$RANDOM
    INDATE=$RANDOM
    OUTDATE=$RANDOM
    echo "insert hotelId $HOTELID inDate $INDATE outDate $OUTDATE customerName $RANDOM number $RANDOM" >&${COPROC[1]}
    # echo "insert hotelId $HOTELID inDate $INDATE outDate $OUTDATE"

    # 30% chance that something crashes
    if [ $RANDOM -lt 9830 ]; then
	echo Killing $COPROC_PID after writing $RECS records.
	kill -9 $COPROC_PID
	wait 2>/dev/null

	# Restart and check database for consistency
	coproc $DB_BINARY
	# echo "Checking database..."
	for k in ${kv[@]}; do
	    HOTELID=${k%%,*}
	    k=${k#*,}
	    INDATE=${k%%,*}
	    k=${k#*,}
	    OUTDATE=$k

	    echo "find hotelId $HOTELID inDate $INDATE outDate $OUTDATE" >&${COPROC[1]}
	    # echo "find hotelId $HOTELID inDate $INDATE outDate $OUTDATE"
	    read -u ${COPROC[0]}
	    test "x$REPLY" != "xfind FOUND" && { echo "Wrong response ($REPLY)! Expected 'find FOUND' in response to "; exit 1; }
	done

	RECS=0
	continue
    fi

    read -u ${COPROC[0]}
    test "x$REPLY" != "xinsert OK" && { echo "Wrong response ($REPLY)! Expected 'insert OK'"; exit 1; }
    kv[$HOTELID,$INDATE,$OUTDATE]="$HOTELID,$INDATE,$OUTDATE"
    let RECS++
done
