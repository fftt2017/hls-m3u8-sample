#!/bin/bash

rm -rf segment*
rm -rf index*
rm -rf *.key

ffmpeg -i ../../demo.mp4 -codec copy -f segment -segment_list index.m3u8 -segment_time 30 segment_%d.ts

encyptionKeyFile="enc.key"
openssl rand 16 > $encyptionKeyFile
encryptionKey=`cat $encyptionKeyFile | hexdump -e '16/1 "%02x"'`
ivKeyFile="iv.key"
openssl rand -hex 16 > $ivKeyFile
ivKey=`cat $ivKeyFile`

splitFilePrefix="segment_"
encryptedSplitFilePrefix="segment_enc_"

numberOfTsFiles=`ls ${splitFilePrefix}*.ts | wc -l`

for ((i=0; i<$numberOfTsFiles; i ++)) do
    openssl aes-128-cbc -e -in ${splitFilePrefix}$i.ts -out ${encryptedSplitFilePrefix}$i.ts -nosalt -iv $ivKey -K $encryptionKey
    rm ${splitFilePrefix}$i.ts
    mv ${encryptedSplitFilePrefix}$i.ts ${splitFilePrefix}$i.ts
done

sed "/#EXT-X-TARGETDURATION:/a #EXT-X-KEY:METHOD=AES-128,URI=\"enc.key\",IV=0x${ivKey}" index.m3u8 > index_new.m3u8


