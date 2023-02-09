FROM ghcr.io/linuxserver/baseimage-alpine:3.16

###############################################################################
# YTDL-RSS INSTALL

# COPY root/ /
WORKDIR /app
RUN apk update --no-cache
RUN apk upgrade --no-cache
RUN wget -O /usr/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
RUN chmod +x /usr/bin/yt-dlp
RUN apk --no-cache add dotnet6-sdk
RUN apk --no-cache add aspnetcore6-runtime
RUN apk --no-cache add ca-certificates python3 py3-pip ffmpeg tzdata nano less ncurses-terminfo-base krb5-libs libgcc libintl libssl1.1 libstdc++ userspace-rcu zlib icu-libs curl lttng-ust
RUN wget -O /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v7.3.1/powershell-7.3.1-linux-alpine-x64.tar.gz
RUN mkdir -p /opt/microsoft/powershell/7
RUN tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
RUN chmod +x /opt/microsoft/powershell/7/pwsh
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
RUN wget -O /tmp/DownloadYouTubev2.tar.gz https://github.com/awirthy/DownloadYouTubev2/archive/refs/tags/v0.20.2.tar.gz
RUN mkdir -p /opt/DownloadYouTubev2
RUN tar zxf /tmp/DownloadYouTubev2.tar.gz -C /opt/DownloadYouTubev2
	###### install mutt
RUN apk --no-cache add mutt
	###### install cron
RUN apk add --update bash
RUN echo "#!/bin/sh" >> /etc/periodic/15min/DownloadYouTubev2
RUN echo "/opt/DownloadYouTubev2/DownloadYouTubev2-0.20.2/DownloadYouTubev2.sh" >> /etc/periodic/15min/DownloadYouTubev2
RUN chmod 755 /opt/DownloadYouTubev2/DownloadYouTubev2-0.20.2/DownloadYouTubev2.sh
RUN chmod 755 /etc/periodic/15min/DownloadYouTubev2
CMD ["crond", "-f","-l","8"]
    
###############################################################################
# CONTAINER CONFIGS

ENV EDITOR="nano" \
#ENV TZ="Australia/Melbourne" \
