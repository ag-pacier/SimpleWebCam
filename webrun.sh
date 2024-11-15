#!/bin/bash

WEBCAM_NAME="POC Camera"
WEBCAM_LABEL="label.txt"
WEBCAM_LOGO="logo.png"

echo $WEBCAM_NAME > $WEBCAM_LABEL
echo $(date '+%A, %b %d, %Y %I:%M %p') >> $WEBCAM_LABEL

nohup ffmpeg -f v4l2 -framerate 10 -video_size 1280x720 -i /dev/video0 -i $WEBCAM_LOGO -f lavfi -i anullsrc -c:v libx264 -preset ultrafast -maxrate 3000k -bufsize 6000k -pix_fmt yuv420p -g 20 -tune zerolatency -crf 35 -filter_complex "overlay=main_w-overlay_w-10:main_h-overlay_h-10,drawtext=textfile=$WEBCAM_LABEL:fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=10:y=h-th-10:reload=3" -f flv rtmp://localhost:1935/live &
sleep 5

while :
do
    if [ $(pgrep -c "ffmpeg") -lt 1 ]
    then
    echo "FFMPEG not running, attempting to restart."
    nohup ffmpeg -f v4l2 -framerate 10 -video_size 1280x720 -i /dev/video0 -i $WEBCAM_LOGO -f lavfi -i anullsrc -c:v libx264 -preset ultrafast -maxrate 3000k -bufsize 6000k -pix_fmt yuv420p -g 20 -tune zerolatency -crf 35 -filter_complex "overlay=main_w-overlay_w-10:main_h-overlay_h-10,drawtext=textfile=$WEBCAM_LABEL:fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=10:y=h-th-10:reload=3" -f flv rtmp://localhost:1935/live &
    sleep 15
    fi

    timestamp=$(date '+%A, %b %d, %Y %I:%M %p')
    echo $WEBCAM_NAME > $WEBCAM_LABEL
    echo $timestamp >> $WEBCAM_LABEL
    sleep 5

done