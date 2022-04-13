#!/bin/bash
# usage: ./find_check.sh input.txt output.txt

CHR='x'
STR=`cat $1 | sed -n '1p' | sed 's/\r//g'`
OUT=`cat $2 | sed -n '2p' | sed 's/\r//g'`
ANS=`echo $STR | grep -o $CHR | wc -l`

if [ "$OUT" == "$ANS" ]; then
    echo 'your answer is correct'
    exit 0
else
    echo 'we got "'$OUT'" when we expected "'$ANS'"'
    exit 1
fi
