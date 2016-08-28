#!/bin/bash

if [ "${1}" != "debug" ]; then
docker run -d --restart=always --name plex  -h OTACON \
 -v plexdata:/config \
 -v tv:/mnt/media/tv \
 -v movies:/mnt/media/movies \
 -p 32400:32400 cau5tik/plex:1.0
else
docker run -t -i -h OTACON \
-v plexdata:/config \
-v tv:/mnt/media/tv \
-v movies:/mnt/media/movies \
-p 32400:32400 cau5tik/plex:1.0 \
/bin/bash
fi

