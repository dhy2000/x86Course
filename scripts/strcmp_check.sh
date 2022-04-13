#!/bin/bash
# usage: ./strcmp_check.sh input.txt output.txt

STR1='DongHanyuan'          # hardcode in assembly
STR2=`cat $1 | sed -n '1p' | sed 's/\r//g'`    # read standard input
OUT=`cat $2 | sed -n '2p' | sed 's/\r//g'`     # read user output

if [ "$STR1" == "$STR2" ]; then
    ANS="$STR1=$STR2"
elif [ "$STR1" \< "$STR2" ]; then
    ANS="$STR1<$STR2"
elif [ "$STR1" \> "$STR2" ]; then
    ANS="$STR1>$STR2"
fi

if ! [ $ANS ]; then
    echo 'internal error'
    exit 1
fi

if [ "$OUT" == "$ANS" ]; then
    echo 'your answer is correct'
    exit 0
else
    echo 'we got "'$OUT'" when we expected "'$ANS'"'
    exit 1
fi
