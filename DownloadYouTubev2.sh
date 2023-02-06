# /etc/cron.d/ytdl
# 
pwsh /opt/DownloadYouTubev2/DownloadYouTubev2-0.20.0/DownloadYouTubev2.ps1  >> /proc/1/fd/1;
echo "DONE"  >> /proc/1/fd/1;