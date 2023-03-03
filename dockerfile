FROM ghcr.io/linuxserver/baseimage-alpine:3.16

###############################################################################
# YTDL-RSS INSTALL

# COPY root/ /
WORKDIR /config
RUN apk update --no-cache
RUN apk upgrade --no-cache
RUN apk add --update bash
RUN apk --no-cache add ca-certificates python3 py3-pip ffmpeg tzdata nano curl
RUN ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
RUN python3 -m pip install -U yt-dlp
RUN pip install beautifulsoup4
RUN pip install lxml
RUN pip install email-validator
RUN python3 -m pip install requests-html
RUN cp /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
RUN echo "Australia/Melbourne" >  /etc/timezone
RUN wget -O /tmp/DownloadYouTubev2.tar.gz https://github.com/awirthy/DownloadYouTubev2/archive/refs/tags/v1.06.0.tar.gz
RUN mkdir -p /opt/DownloadYouTubev2
RUN tar zxf /tmp/DownloadYouTubev2.tar.gz -C /opt/DownloadYouTubev2
RUN echo "#!/bin/sh" >> /etc/periodic/15min/DownloadYouTubev2
RUN echo "/opt/DownloadYouTubev2/DownloadYouTubev2-1.06.0/DownloadYouTubev2.sh" >> /etc/periodic/15min/DownloadYouTubev2
RUN chmod 755 /opt/DownloadYouTubev2/DownloadYouTubev2-1.06.0/DownloadYouTubev2.sh
RUN chmod 755 /etc/periodic/15min/DownloadYouTubev2
CMD ["crond", "-f","-l","8"]
    
###############################################################################
# CONTAINER CONFIGS

ENV EDITOR="nano" \
#ENV TZ="Australia/Melbourne" \
