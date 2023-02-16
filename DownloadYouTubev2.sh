# /etc/cron.d/ytdl
# 
python3 /opt/DownloadYouTubev2/DownloadYouTubev2-1.01.0/DownloadYouTubev2.py  >> /proc/1/fd/1;
echo "DONE"  >> /proc/1/fd/1;