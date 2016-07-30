#!/bin/bash

IFS="
"

f="$1"

split_uuid=$(uuidgen)
mkdir -p /tmp/$split_uuid
sox \
  "$f" "/tmp/$split_uuid/${f%%.*}.wav" \
  silence -l 1 0.0 -40d 1 1.0 -40d : newfile : restart

trim_uuid=$(uuidgen)
mkdir -p /tmp/$trim_uuid
for f in /tmp/$split_uuid/*.wav; do
  nf=`basename $f`
  sox \
    "$f" "/tmp/$trim_uuid/$nf" \
    silence 1 0.1 0.1% reverse silence 1 0.1 0.1% reverse
done

fade_uuid=$(uuidgen)
mkdir -p /tmp/$fade_uuid
for f in /tmp/$trim_uuid/*.wav; do
  nf=`basename $f`
  sox \
    "$f" "/tmp/$fade_uuid/$nf" \
    fade 0.004 0 0.004
done

norm_uuid=$(uuidgen)
mkdir -p /tmp/$norm_uuid
for f in /tmp/$fade_uuid/*.wav; do
  nf=`basename $f`
  vval=`sox "$f" -n stat -v 2>&1 | { read v; echo "$v - 0.02"; } | bc`
  sox \
    -v $vval \
    "$f" "/tmp/$norm_uuid/$nf"
done

cp /tmp/$norm_uuid/*.wav .

rm -rf /tmp/$split_uuid
rm -rf /tmp/$trim_uuid
rm -rf /tmp/$fade_uuid
rm -rf /tmp/$norm_uuid



