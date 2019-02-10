#!/bin/bash

docker run -d --restart=always --name plex  -h OTACON \
-v /tank/plexdata:/config \
-v /tank/tv:/mnt/media/tv \
-v /tank/movies:/mnt/media/movies \
-v /tank/home_movies:/mnt/media/home_movies \
-v /tank/music_videos:/mnt/media/music_videos \
-p 32400:32400 cau5tik/plex:latest
# cau5tik/plex:1.5

