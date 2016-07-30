#!/bin/bash

IFS="
"

f="$1"

split_uuid=$(uuidgen)
mkdir -p /tmp/$split_uuid
sox \
  "$f" "/tmp/$split_uuid/${f%%.*}.wav" \
  silence -l 1 0.0 -40d 1 1.0 -40d : newfile : restart
if [[ $? != 0 ]]; then
  echo "SPLIT error"
  exit 1
fi


trim_uuid=$(uuidgen)
mkdir -p /tmp/$trim_uuid
for f in `find /tmp/$split_uuid -type f -name "*.wav" -size +4k`; do
  nf=`basename $f`
  sox \
    "$f" "/tmp/$trim_uuid/$nf" \
    silence 1 0.1 0.1% reverse silence 1 0.1 0.1% reverse
done
if [[ $? != 0 ]]; then
  echo "TRIM error"
  exit 1
fi

fade_uuid=$(uuidgen)
mkdir -p /tmp/$fade_uuid
for f in `find /tmp/$trim_uuid -type f -name "*.wav" -size +4k`; do
  nf=`basename $f`
  sox \
    "$f" "/tmp/$fade_uuid/$nf" \
    fade 0.004 0 0.004
done
if [[ $? != 0 ]]; then
  echo "FADE error"
  exit 1
fi

norm_uuid=$(uuidgen)
mkdir -p /tmp/$norm_uuid
for f in `find /tmp/$fade_uuid -type f -name "*.wav"`; do
  nf=`basename $f`
  vval=`sox "$f" -n stat -v 2>&1 | { read v; echo "$v - 0.02"; } | bc`
  sox \
    -v $vval \
    "$f" "/tmp/$norm_uuid/$nf"
done
if [[ $? != 0 ]]; then
  echo "NORM error"
  exit 1
fi

for f in `find /tmp/$norm_uuid -type f -name "*.wav"`; do
  cp "$f" .
done

rm -rf /tmp/$split_uuid
rm -rf /tmp/$trim_uuid
rm -rf /tmp/$fade_uuid
rm -rf /tmp/$norm_uuid

exit 0


