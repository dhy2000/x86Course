#!/bin/bash
# usage: ./sort_check.sh input.txt output.txt

# string in list shouldn't contains any whitespaces.

function sortstr() {
    # `sort` has letter-case bug in manjaro, but works well in ubuntu.
    echo "$1" | sed 's/\r//g' | tr ' ' '\n' | sort | tr '\n' ' ' | sed -e 's/[ ]*$//g'
}

TABLE=`cat $2 | sed 's/\r//g' | sed -n '1p'`

SORTED_TABLE_STD=`sortstr "$TABLE"`
SORTED_TABLE=`cat $2 | sed 's/\r//g' | sed -n '2p'`

if [ "$SORTED_TABLE_STD" != "$SORTED_TABLE" ]; then
    echo "sort error"
    exit 1
fi

INPUT_STR=`cat $1 | sed 's/\r//g' | sed -n '1p'`
INSERT_TABLE=`echo -e "$TABLE $INPUT_STR"`
SORTED_INSERT_TABLE_STD=`sortstr "$INSERT_TABLE"`
SORTED_INSERT_TABLE=`cat $2 | sed 's/\r//g' | sed -n '4p'`

if [ "$SORTED_INSERT_TABLE_STD" != "$SORTED_INSERT_TABLE" ]; then
    echo "insert and sort error"
    exit 1
fi

echo 'your answer is correct'

