#!/bin/bash

if ${#WEBCAM_NAME} -lt 2
then
echo "No webcam name set, please set and try again"
exit 1
fi

echo $WEBCAM_NAME > ~./label.txt
echo ${date +"%A, %b %d, %Y %I:%M %p"} >> ~./label.txt

ffmpeg -f v4l2 -framerate 10 -video_size 1280x720 -i /dev/video0 -f lavfi -i anullsrc -c:v libx264 -preset ultrafast -maxrate 3000k -bufsize 6000k -pix_fmt yuv420p -g 20 -tune zerolatency -crf 35 -vf "drawtext=textfile=~./label.txt:fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=10:y=h-th-10" -f flv rtmp://localhost:1935/live &
sleep 5

while :
do
    if ${pgrep -c "ffmpeg"} -lt 1
    then
    echo "FFMPEG not running, attempting to restart."
    ffmpeg -f v4l2 -framerate 10 -video_size 1280x720 -i /dev/video0 -f lavfi -i anullsrc -c:v libx264 -preset ultrafast -maxrate 3000k -bufsize 6000k -pix_fmt yuv420p -g 20 -tune zerolatency -crf 35 -vf "drawtext=textfile=~./label.txt:fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=10:y=h-th-10" -f flv rtmp://localhost:1935/live &
    sleep 10
    fi

    timestamp=${date +"%A, %b %d, %Y %I:%M %p"}

    if [ ! -z $(grep "$timestamp" ~./label.txt) ]
    then sleep 2
    else
    echo $WEBCAM_NAME > ~./label.txt
    echo ${date +"%A, %b %d, %Y %I:%M %p"} >> ~./label.txt
    sleep 40
    fi

done