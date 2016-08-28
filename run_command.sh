#!/bin/bash

if [ "${1}" != "debug" ]; then
docker run -d --restart=always --name plex  -h OTACON \
--volume-driver=nfs \
 -v plexdata:/config \
 -v tv:/mnt/media/tv \
 -v movies:/mnt/media/movies \
 -p 32400:32400 cau5tik/plex:1.3
else
docker run -t -i -h OTACON \
--volume-driver=nfs \
-v plexdata:/config \
-v tv:/mnt/media/tv \
-v movies:/mnt/media/movies \
-p 32400:32400 cau5tik/plex:1.3 \
/bin/bash
fi

