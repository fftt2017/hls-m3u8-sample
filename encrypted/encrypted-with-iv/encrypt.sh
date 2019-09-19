#!/bin/bash

rm -rf segment_enc_*

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
done

sed "/#EXT-X-TARGETDURATION:/a #EXT-X-KEY:METHOD=AES-128,URI=\"enc.key\",IV=${ivKey}" index.m3u8 > index_new.m3u8


