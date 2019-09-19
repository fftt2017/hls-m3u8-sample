#!/bin/bash

rm -rf segment*
rm -rf index*

ffmpeg -i ../demo.mp4 -codec copy -f segment -segment_list index.m3u8 -segment_time 30 segment_%d.ts
