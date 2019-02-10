FROM plexinc/pms-docker:latest
MAINTAINER Tim Haak <tim@haak.co>

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm"

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -q update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy \
      iproute2 \
      ca-certificates \
      ffmpeg \
      git \
      jq \
      openssl \
      xmlstarlet \
      curl \
      sudo \
      wget \
      unzip \
    && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

#ARG PLEX_PASS='false'
#ARG PLEX_TOKEN=''
#
#RUN if [ "${PLEX_PASS}" = "true" ]; then PLEX_TYPE_FLAG="--token=${PLEX_TOKEN}" ; fi && \
#    git clone --depth 1 https://github.com/mrworf/plexupdate.git /plexupdate && \
#    /plexupdate/plexupdate.sh ${PLEX_TYPE_FLAG} -a -d  && \
#    apt-get -y purge git &&\
#    apt-get -y autoremove && \
#    apt-get -y clean && \
#    rm -rf /var/lib/apt/lists/* && \
#    rm -rf /tmp/*

ENV RUN_AS_ROOT="false" \
    CHANGE_DIR_RIGHTS="false" \
    CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    HOME="/config" \
    PLEX_DISABLE_SECURITY=1 \
    PLEX_ALLOWED_NETWORKS="192.168.15.0/24"

# I never use all these ports
#EXPOSE 32400 1900/udp 3005 5353/udp 8324 32410/udp 32412/udp 32413/udp 32414/udp 32469
EXPOSE 32400


# these are commented out in this new dockerfile. including them seems to break things :/
#COPY ./Preferences.xml /Preferences.xml
#COPY ./start.sh /start.sh

#CMD ["/start.sh"]
