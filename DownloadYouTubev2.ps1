Set-StrictMode -Version 2
# pwsh /config/DownloadYouTube_v1.30.ps1
# pwsh DownloadYouTube_v2.00.ps1  >> /proc/1/fd/1;

#
# ─── TO UPDATE ──────────────────────────────────────────────────────────────────
#

# python3 -m pip install -U yt-dlp

function Send-ToEmail([string]$email,[string]$subject,[string]$body){

    curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-from 'a.wirthy@gmail.com' --mail-rcpt "${email}" --user 'a.wirthy@gmail.com:vtdviddmjlkyqcuf' -F from='a.wirthy@gmail.com' -F to=a.wirthy@gmail.com -H "Subject: ${subject}" --form-string html="${body}";
    write-host "Mail Sent" ; 
 }

function Send-ToEmail-Error([string]$email,[string]$subject,[string]$body,[string]$AttFile){
    curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-from 'a.wirthy@gmail.com' --mail-rcpt 'a.wirthy@gmail.com' --user 'a.wirthy@gmail.com:vtdviddmjlkyqcuf' -F from='a.wirthy@gmail.com' -F to=a.wirthy@gmail.com -H "Subject: ${subject}" --form-string html="${body}" -F attachment="@${AttFile}";
    # --upload-file "$AttFile"

    Write-to_Log -title "Email Sent" -content "Sent";
 }

function Write-to_Log([string]$title,[string]$content){
    $CurrentDate = (Get-Date -format "dd/MM/yyyy hh:mm tt");
    write-host "${CurrentDate} - ${title}: ${content}"
    # echo "${CurrentDate} - ${title}: ${content}";
 }

function Create_RSS_v1([string]$ChannelID,[string]$RSSXML,[string]$MediaFolder){
    $objStartFolder = "${MediaFolder}${ChannelID}/*.*";
    $files = Get-ChildItem $objStartFolder;

    foreach ($file in $files) {
        $filename = $file.name;
        if ($filename.contains(".mp4")) {
            if ((($filename.contains("temp.mp4") -ne $true) -and ($filename.contains("].mp4") -eq $true)) -or ($filename.contains("1000k.mp4") -eq $true)) {
                
                Write-to_Log -title "Contains MP4" -content "${filename}";
                $VideoURL = $file.Name;
                $strTitle = $VideoURL;
                $VideoURL = [uri]::EscapeUriString($VideoURL);
                $strDescription = "";
                $strFile = "/data/rss/${RSSXML}.xml";
                $LastVideo = Get-Content $strFile;
                $txtRSSFile = $LastVideo;
                $CurrentDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"Australia/Sydney");
                $guid = $CurrentDate;
                $guid = (Get-Date -Date "$CurrentDate" -Format 'dd/MM/yyyy hh:mm:ss:fff');
                $pubDate = (Get-Date -Date "$CurrentDate" -Format 'ddd, dd MMM yyyy hh:mm:ss +1000');

                $SEL = Select-String -InputObject $LastVideo -SimpleMatch "$strTitle";

                if ($SEL -eq $null) {
                    
                    Write-to_Log -title "Added to RSS" -content "${filename}";
                    $txtRSS = "";
                    $txtRSS = "</item><item>$([Environment]::NewLine)<title>${strTitle}</title>$([Environment]::NewLine)<link>http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}</link>$([Environment]::NewLine)<description><![CDATA[${strDescription}]]></description>$([Environment]::NewLine)<dc:creator xmlns:dc=""http://purl.org/dc/elements/1.1/"">${ChannelID}</dc:creator>$([Environment]::NewLine)<pubDate>${pubDate}</pubDate>$([Environment]::NewLine)<guid isPermaLink=""false"">${guid}</guid>$([Environment]::NewLine)<enclosure url=""http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}"" length=""0"" type=""video/mp4""/>$([Environment]::NewLine)";
                    $txtRSSFile = $txtRSSFile.replace("</item></channel></rss>","${txtRSS}</item></channel></rss>");
                    # Set-Content -Path $strFile -Value "${txtRSSFile}";
                    Out-File -FilePath $strFile -InputObject $txtRSSFile;
                    # Send-ToEmail -email "mphfckm6ji@pomail.net" -subject "RSS Podcast Downloaded (${ChannelID})" -body "${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";

                    # $htmltext = "From: a.wirthy@gmail.com$([Environment]::NewLine)To: mphfckm6ji@pomail.net$([Environment]::NewLine)Subject: RSS Podcast Downloaded (${ChannelID})$([Environment]::NewLine)${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";
                    $htmltext = "${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";
                    Out-File -FilePath "/config/pushovernotify.txt" -InputObject $htmltext;
                    # cat /config/pushovernotify.txt | msmtp -a gmail mphfckm6ji@pomail.net
                    cat "/config/pushovernotify.txt" | mutt -s "RSS Podcast Downloaded (${ChannelID})" -- mphfckm6ji@pomail.net;
                    # $FileToChangeDate = Get-Item "/data/rss/podcasts/${ChannelID}/${VideoURL}";
                    # $FileToChangeDate.LastWriteTime = (get-date);
                    # $FileToChangeDate.LastWriteTime = (get-date);

                }
            } elseif ($filename.contains("].mp3") -eq $true) {
                
                Write-to_Log -title "Contains MP3" -content "${filename}";
                $VideoURL = $file.Name;
                $strTitle = $VideoURL;
                $VideoURL = [uri]::EscapeUriString($VideoURL);
                $strDescription = "";
                $strFile = "/data/rss/${RSSXML}.xml";
                $LastVideo = Get-Content $strFile;
                $txtRSSFile = $LastVideo;
                $CurrentDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"Australia/Sydney");
                $guid = $CurrentDate;
                $guid = (Get-Date -Date "$CurrentDate" -Format 'dd/MM/yyyy hh:mm:ss:fff');
                $pubDate = (Get-Date -Date "$CurrentDate" -Format 'ddd, dd MMM yyyy hh:mm:ss +1000');

                $SEL = Select-String -InputObject $LastVideo -SimpleMatch "$strTitle";

                if ($SEL -eq $null) {
                    
                    Write-to_Log -title "Added to RSS" -content "${filename}";

                    $txtRSS = "";
                    $txtRSS = "</item><item>$([Environment]::NewLine)<title>${strTitle}</title>$([Environment]::NewLine)<link>http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}</link>$([Environment]::NewLine)<description><![CDATA[${strDescription}]]></description>$([Environment]::NewLine)<dc:creator xmlns:dc=""http://purl.org/dc/elements/1.1/"">${ChannelID}</dc:creator>$([Environment]::NewLine)<pubDate>${pubDate}</pubDate>$([Environment]::NewLine)<guid isPermaLink=""false"">${guid}</guid>$([Environment]::NewLine)<enclosure url=""http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}"" length=""0"" type=""video/mp3""/>$([Environment]::NewLine)";
                    $txtRSSFile = $txtRSSFile.replace("</item></channel></rss>","${txtRSS}</item></channel></rss>");
                    # Set-Content -Path $strFile -Value "${txtRSSFile}";
                    Out-File -FilePath $strFile -InputObject $txtRSSFile;
                    # Send-ToEmail -email "mphfckm6ji@pomail.net" -subject "RSS Podcast Downloaded (${ChannelID})" -body "${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";

                    # $htmltext = "From: a.wirthy@gmail.com$([Environment]::NewLine)To: mphfckm6ji@pomail.net$([Environment]::NewLine)Subject: RSS Podcast Downloaded (${ChannelID})$([Environment]::NewLine)${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";
                    $htmltext = "${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";
                    Out-File -FilePath "/config/pushovernotify.txt" -InputObject $htmltext;
                    # cat /config/pushovernotify.txt | msmtp -a gmail mphfckm6ji@pomail.net
                    cat "/config/pushovernotify.txt" | mutt -s "RSS Podcast Downloaded (${ChannelID})" -- mphfckm6ji@pomail.net;
                }
            }
        }
    }
 }

function Create_RSS([string]$ChannelID,[string]$RSSXML,[string]$MediaFolder){
    $objStartFolder = "${MediaFolder}${ChannelID}/*.*";
    $files = Get-ChildItem $objStartFolder;

    foreach ($file in $files) {
        $filename = $file.name;
        if ($filename.contains(".mp4")) {
            if ((($filename.contains("temp.mp4") -ne $true) -and ($filename.contains("].mp4") -eq $true)) -or ($filename.contains("1000k.mp4") -eq $true)) {
                
                Write-to_Log -title "Contains MP4" -content "${filename}";
                $VideoURL = $file.Name;
                $strTitle = $VideoURL;
                $VideoURL = [uri]::EscapeUriString($VideoURL);
                $strDescription = "";
                $strFile = "/data/rss/${RSSXML}.xml";
                $LastVideo = Get-Content $strFile;
                $txtRSSFile = $LastVideo;
                $CurrentDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"Australia/Sydney");
                $guid = $CurrentDate;
                $guid = (Get-Date -Date "$CurrentDate" -Format 'dd/MM/yyyy hh:mm:ss:fff');
                $pubDate = (Get-Date -Date "$CurrentDate" -Format 'ddd, dd MMM yyyy hh:mm:ss +1000');

                $SEL = Select-String -InputObject $LastVideo -SimpleMatch "$strTitle";

                if ($SEL -eq $null) {
                    #
                    # READ JSON FILE
                    #
                    $JSONURL = $VideoURL.replace(".mp4",".info.json")
                    
                    Write-to_Log -title "JSON Path" -content "${MediaFolder}${ChannelID}/${JSONURL}";
                    $txtRSS = "";
                    $filename = $JSONURL;
                    $filepath = "${MediaFolder}${ChannelID}/${JSONURL}";
                    $testpathjson = Test-Path -LiteralPath "${filepath}";
                    Write-to_Log -title "filepath" -content "${filepath}";
                    Write-to_Log -title "testpathjson" -content "${testpathjson}";

                    if ($testpathjson -eq $true) {
                        $json_data = Get-Content -LiteralPath "$filepath";
                        $yt_videos = $json_data | ConvertFrom-Json;

                        foreach ($ytvideo in $yt_videos)
                        {
                            $htmltext = "<html><body>$($ytvideo.title)<br /><br />--------------------------------------------<br /><br />$($ytvideo.description)</body></html>";
                            Out-File -FilePath "/config/json/pushovernotify2.txt" -InputObject $htmltext -Force;
                            wget -O "/config/json/maxresdefault2.jpg" $($ytvideo.thumbnail);
                            
                            $ytvideouploader = $($ytvideo.uploader);
                            $ytvideoid = $($ytvideo.id);
                            $ytvideothumbnail = $($ytvideo.thumbnail);
                            $ytvideotitle = $($ytvideo.title);
                            $ytvideodescription = $($ytvideo.description);
                            $ytvideodescription = $ytvideodescription.replace($([Environment]::NewLine),"<br />");
                            $ytvideodescription = "<p>${ytvideodescription}</p>";
                        }
                        cat "/config/json/pushovernotify2.txt" | mutt -a "/config/json/maxresdefault2.jpg" -s "RSS Podcast Downloaded (${ChannelID})" -- mphfckm6ji@pomail.net;
                        # Remove-Item -LiteralPath $filepath -Force;
                        $txtRSS = "</item><item>$([Environment]::NewLine)<title><![CDATA[${ytvideotitle}]]></title>$([Environment]::NewLine)<link>http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}</link>$([Environment]::NewLine)<description><![CDATA[${ytvideodescription}]]></description>$([Environment]::NewLine)<dc:creator xmlns:dc=""http://purl.org/dc/elements/1.1/"">${ChannelID}</dc:creator>$([Environment]::NewLine)<pubDate>${pubDate}</pubDate>$([Environment]::NewLine)<guid isPermaLink=""false"">${guid}</guid>$([Environment]::NewLine)<enclosure url=""http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}"" length=""0"" type=""video/mp4""/>$([Environment]::NewLine)";
                    } else {
                        $htmltext = "${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";
                        Out-File -FilePath "/config/pushovernotify.txt" -InputObject $htmltext;
                        cat "/config/pushovernotify.txt" | mutt -s "RSS Podcast Downloaded (${ChannelID})" -- mphfckm6ji@pomail.net;
                        $txtRSS = "</item><item>$([Environment]::NewLine)<title>${strTitle}</title>$([Environment]::NewLine)<link>http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}</link>$([Environment]::NewLine)<description><![CDATA[${strDescription}]]></description>$([Environment]::NewLine)<dc:creator xmlns:dc=""http://purl.org/dc/elements/1.1/"">${ChannelID}</dc:creator>$([Environment]::NewLine)<pubDate>${pubDate}</pubDate>$([Environment]::NewLine)<guid isPermaLink=""false"">${guid}</guid>$([Environment]::NewLine)<enclosure url=""http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}"" length=""0"" type=""video/mp4""/>$([Environment]::NewLine)";
                    }
                    #
                    # -
                    #

                    Write-to_Log -title "Added to RSS" -content "${filepath}";
                    # $txtRSS = "";
                    # $txtRSS = "</item><item>$([Environment]::NewLine)<title>${ytvideotitle}</title>$([Environment]::NewLine)<link>http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}</link>$([Environment]::NewLine)<description><![CDATA[${ytvideodescription}]]></description>$([Environment]::NewLine)<dc:creator xmlns:dc=""http://purl.org/dc/elements/1.1/"">${ChannelID}</dc:creator>$([Environment]::NewLine)<pubDate>${pubDate}</pubDate>$([Environment]::NewLine)<guid isPermaLink=""false"">${guid}</guid>$([Environment]::NewLine)<enclosure url=""http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}"" length=""0"" type=""video/mp4""/>$([Environment]::NewLine)";
                    $txtRSSFile = $txtRSSFile.replace("</item></channel></rss>","${txtRSS}</item></channel></rss>");
                    # Set-Content -Path $strFile -Value "${txtRSSFile}";
                    Out-File -FilePath $strFile -InputObject $txtRSSFile;
                    # Send-ToEmail -email "mphfckm6ji@pomail.net" -subject "RSS Podcast Downloaded (${ChannelID})" -body "${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";

                    # $htmltext = "From: a.wirthy@gmail.com$([Environment]::NewLine)To: mphfckm6ji@pomail.net$([Environment]::NewLine)Subject: RSS Podcast Downloaded (${ChannelID})$([Environment]::NewLine)${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";
                    # $htmltext = "${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";
                    # Out-File -FilePath "/config/pushovernotify.txt" -InputObject $htmltext;
                    # cat /config/pushovernotify.txt | msmtp -a gmail mphfckm6ji@pomail.net
                    # cat "/config/pushovernotify.txt" | mutt -s "RSS Podcast Downloaded (${ChannelID})" -- mphfckm6ji@pomail.net;
                    # $FileToChangeDate = Get-Item "/data/rss/podcasts/${ChannelID}/${VideoURL}";
                    # $FileToChangeDate.LastWriteTime = (get-date);
                    # $FileToChangeDate.LastWriteTime = (get-date);

                }
            } elseif ($filename.contains("].mp3") -eq $true) {
                Write-to_Log -title "Contains MP3" -content "${filename}";
                $VideoURL = $file.Name;
                $strTitle = $VideoURL;
                $VideoURL = [uri]::EscapeUriString($VideoURL);
                $strDescription = "";
                $strFile = "/data/rss/${RSSXML}.xml";
                $LastVideo = Get-Content $strFile;
                $txtRSSFile = $LastVideo;
                $CurrentDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"Australia/Sydney");
                $guid = $CurrentDate;
                $guid = (Get-Date -Date "$CurrentDate" -Format 'dd/MM/yyyy hh:mm:ss:fff');
                $pubDate = (Get-Date -Date "$CurrentDate" -Format 'ddd, dd MMM yyyy hh:mm:ss +1000');

                $SEL = Select-String -InputObject $LastVideo -SimpleMatch "$strTitle";

                if ($SEL -eq $null) {
                    #
                    # READ JSON FILE
                    #
                    $JSONURL = $VideoURL.replace(".mp4",".info.json")
                    Write-to_Log -title "JSONFILE" -content "${MediaFolder}${ChannelID}/${JSONURL}";
                    $txtRSS = "";
                    $filename = $JSONURL;
                    $filepath = "${MediaFolder}${ChannelID}/${JSONURL}";
                    $testpathjson = Test-Path -LiteralPath "${filepath}";
                    Write-to_Log -title "filepath" -content "${filepath}";
                    Write-to_Log -title "testpathjson" -content "${testpathjson}";
                    
                    if ($testpathjson -eq $true) {
                        $json_data = Get-Content -LiteralPath "$filepath";
                        $yt_videos = $json_data | ConvertFrom-Json;

                        foreach ($ytvideo in $yt_videos)
                        {
                            # $htmltext = "<html><body>$($ytvideo.title)<br /><br />--------------------------------------------<br /><br />$($ytvideo.description)</body></html>";
                            Out-File -FilePath "/config/json/pushovernotify2.txt" -InputObject $htmltext -Force;
                            wget -O "/config/json/maxresdefault2.jpg" $($ytvideo.thumbnail);
                            
                            $ytvideouploader = $($ytvideo.uploader);
                            $ytvideoid = $($ytvideo.id);
                            $ytvideothumbnail = $($ytvideo.thumbnail);
                            $ytvideotitle = $($ytvideo.title);
                            $ytvideodescription = $($ytvideo.description);
                            $ytvideodescription = $ytvideodescription.replace($([Environment]::NewLine),"<br />");
                            $ytvideodescription = "<p>${ytvideodescription}</p>";
                            $htmltext = "<html><body>$($ytvideo.title)<br /><br />--------------------------------------------<br /><br />${ytvideodescription}</body></html>";
                        }
                        cat "/config/json/pushovernotify2.txt" | mutt -a "/config/json/maxresdefault2.jpg" -s "RSS Podcast Downloaded (${ChannelID})" -- mphfckm6ji@pomail.net;
                        Remove-Item -LiteralPath $filepath -Force;
                        $txtRSS = "</item><item>$([Environment]::NewLine)<title><![CDATA[${ytvideotitle}]]></title>$([Environment]::NewLine)<link>http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}</link>$([Environment]::NewLine)<description><![CDATA[${ytvideodescription}]]></description>$([Environment]::NewLine)<dc:creator xmlns:dc=""http://purl.org/dc/elements/1.1/"">${ChannelID}</dc:creator>$([Environment]::NewLine)<pubDate>${pubDate}</pubDate>$([Environment]::NewLine)<guid isPermaLink=""false"">${guid}</guid>$([Environment]::NewLine)<enclosure url=""http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}"" length=""0"" type=""video/mp3""/>$([Environment]::NewLine)";
                    } else {
                        $htmltext = "${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";
                        Out-File -FilePath "/config/pushovernotify.txt" -InputObject $htmltext;
                        cat "/config/pushovernotify.txt" | mutt -s "RSS Podcast Downloaded (${ChannelID})" -- mphfckm6ji@pomail.net;
                        $txtRSS = "</item><item>$([Environment]::NewLine)<title>${strTitle}</title>$([Environment]::NewLine)<link>http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}</link>$([Environment]::NewLine)<description><![CDATA[${strDescription}]]></description>$([Environment]::NewLine)<dc:creator xmlns:dc=""http://purl.org/dc/elements/1.1/"">${ChannelID}</dc:creator>$([Environment]::NewLine)<pubDate>${pubDate}</pubDate>$([Environment]::NewLine)<guid isPermaLink=""false"">${guid}</guid>$([Environment]::NewLine)<enclosure url=""http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}"" length=""0"" type=""video/mp3""/>$([Environment]::NewLine)";
                    }
                    
                    #
                    # -
                    #

                    Write-to_Log -title "Added to RSS" -content "${filepath}";
                    # $txtRSS = "";
                    # $txtRSS = "</item><item>$([Environment]::NewLine)<title>${ytvideotitle}</title>$([Environment]::NewLine)<link>http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}</link>$([Environment]::NewLine)<description><![CDATA[${ytvideodescription}]]></description>$([Environment]::NewLine)<dc:creator xmlns:dc=""http://purl.org/dc/elements/1.1/"">${ChannelID}</dc:creator>$([Environment]::NewLine)<pubDate>${pubDate}</pubDate>$([Environment]::NewLine)<guid isPermaLink=""false"">${guid}</guid>$([Environment]::NewLine)<enclosure url=""http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}"" length=""0"" type=""video/mp3""/>$([Environment]::NewLine)";
                    $txtRSSFile = $txtRSSFile.replace("</item></channel></rss>","${txtRSS}</item></channel></rss>");
                    # Set-Content -Path $strFile -Value "${txtRSSFile}";
                    Out-File -FilePath $strFile -InputObject $txtRSSFile;
                    # Send-ToEmail -email "mphfckm6ji@pomail.net" -subject "RSS Podcast Downloaded (${ChannelID})" -body "${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";

                    # $htmltext = "From: a.wirthy@gmail.com$([Environment]::NewLine)To: mphfckm6ji@pomail.net$([Environment]::NewLine)Subject: RSS Podcast Downloaded (${ChannelID})$([Environment]::NewLine)${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";
                    # $htmltext = "${strTitle}$([Environment]::NewLine)$([Environment]::NewLine)---------------------------------------------------------------$([Environment]::NewLine)$([Environment]::NewLine)${strDescription}";
                    # Out-File -FilePath "/config/pushovernotify.txt" -InputObject $htmltext;
                    # cat /config/pushovernotify.txt | msmtp -a gmail mphfckm6ji@pomail.net
                    # cat "/config/pushovernotify.txt" | mutt -s "RSS Podcast Downloaded (${ChannelID})" -- mphfckm6ji@pomail.net;
                }
            }
        }
    }
 }

function Create_RSS_v3([string]$ChannelID,[string]$RSSXML,[string]$MediaFolder,[string]$YouTubeURL,[string]$FileFormat,[string]$DownloadArchive,[string]$FileQuality,[string]$ChannelThumbnail){
    # yt-dlp -v -o "/config/json/videos/%(title)s_[%(id)s].%(ext)s" --skip-download -I 1:5 --write-info-json --no-write-playlist-metafiles --restrict-filenames --download-archive "/config/json/youtube-dl-notify.txt" --add-metadata --merge-output-format mp4 --format "best" --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue "${URL}";
    $DownloadPath = "${MediaFolder}${ChannelID}";
    
    #
    # ─── IF FOLDER DOESNT EXIST CREATE FOLDER ───────────────────────────────────────
    #
        
    if (Test-Path -LiteralPath $DownloadPath) {
        Write-to_Log -title "DownloadPath Valid" -content "${DownloadPath}";
    } else {
        Write-to_Log -title "DownloadPath Invalid" -content "${DownloadPath}";
        mkdir "${DownloadPath}";
    }

    #
    # ─── DOWNLOAD VIDEO ─────────────────────────────────────────────────────────────
    #

    Write-to_Log -title "Download Video Files for" -content "${ChannelID}";
    yt-dlp -v -o "${MediaFolder}${ChannelID}/%(title)s_[%(id)s].%(ext)s" --write-info-json --external-downloader aria2c --external-downloader-args "-c -j 10 -x 10 -s 10 -k 1M" --playlist-items 1,2,3,4,5 --restrict-filenames --download-archive "${DownloadArchive}" --add-metadata --merge-output-format "${FileFormat}" --format "${FileQuality}" --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue --write-description "${YouTubeURL}";
    # yt-dlp -v -o "${MediaFolder}${ChannelID}/%(title)s_[%(id)s].%(ext)s" --write-info-json --playlist-items 1,2,3,4,5 --restrict-filenames --download-archive "${DownloadArchive}" --add-metadata --merge-output-format "${FileFormat}" --format "${FileQuality}" --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue --write-description "${YouTubeURL}";

    #
    # ─── CHECK FOR VALID RSS FILE ───────────────────────────────────────────────────
    #

    $RSSPath = "/data/rss/${RSSXML}.xml";
    $JSON_Channel_File = "";

    if (Test-Path -LiteralPath $RSSPath) {
        Write-to_Log -title "RSSPath Valid" -content "${RSSPath}";
    } else {
        Write-to_Log -title "RSSPath Invalid" -content "${RSSPath}";
        Copy-Item -Path "/data/RSS_TEMPLATE_2.0.xml" -Destination "/data/rss/${RSSXML}.xml";

        #
        # ─── FIND DOWNLOADED JSON FILE TO GET VALUES FROM FOR RSS ────────
        #

        $objStartFolder = "${DownloadPath}/*.json";
        Write-to_Log -title "objStartFolder" -content "${objStartFolder}";
        $jsonfiles = Get-ChildItem $objStartFolder;
        $jsonfilecount = 0;

        foreach ($file in $jsonfiles) {
            $jsonfilecount++;
            $filename = $file.name;
            $filepath = $file.FullName;
            $jsonpathtest = $filepath.Replace(".info.json",".mp4");

            if (Test-Path -LiteralPath $jsonpathtest)
            {
                Write-to_Log -title "GET VIDEO JSON INFORMATION" -content "${jsonpathtest}";

                # if ($jsonfilecount -eq 1) {

                #
                # GET VALUES FROM JSON FILE
                #

                $json_data = Get-Content -LiteralPath "$filepath";
                $yt_videos = $json_data | ConvertFrom-Json;


                foreach ($ytvideo in $yt_videos)
                {
                    # write-host "$($ytvideo.title), uploader: $($ytvideo.uploader)";
                    $ytvideo_uid = $ytvideo.id;
                    $ytvideo_title = $ytvideo.title;
                    $ytvideo_thumbnail = $ytvideo.thumbnail;
                    $ytvideo_description = $ytvideo.description;
                    $ytvideo_uploader = $ytvideo.uploader;
                    $ytvideo_uploader_url = $ytvideo.uploader_url;
                    $ytvideo_channel_id = $ytvideo.channel_id;
                    $ytvideo_channel_url = $ytvideo.channel_url;
                    $ytvideo_duration = $ytvideo.duration;
                    $ytvideo_webpage_url = $ytvideo.webpage_url;
                    $ytvideo_filesize = $ytvideo.filesize_approx;
                }

                #
                # ─── SET VALUES IN DEFAULT RSS FILE ──────────────────────────────
                #

                $RSSData = Get-Content -LiteralPath "/data/rss/${RSSXML}.xml";
                $RSSData = $RSSData.Replace("[ITEM_TITLE]","$ytvideo_title");
                $RSSData = $RSSData.Replace("[PODCAST_TITLE]","$ytvideo_uploader");
                
                $RSSData = $RSSData.Replace("[CHANNEL_LINK]","$ytvideo_channel_url");
                Set-Content -LiteralPath "/data/rss/${RSSXML}.xml" -Value "$RSSData";
                # }
            } else {
                Write-to_Log -title "GET CHANNEL JSON INFORMATION" -content "${jsonpathtest}";

                $json_data = Get-Content -LiteralPath "$filepath";
                $yt_videos = $json_data | ConvertFrom-Json;


                foreach ($ytvideo in $yt_videos)
                {
                    $ytchannel_title = $ytvideo.title;
                    $ytchannel_description = $ytvideo.description;
                    $ytchannel_description = $ytchannel_description.replace($([Environment]::NewLine),"<br />");
                    $ytchannel_description = "<p>${ytchannel_description}</p>";
                    $ytchannel_thumbnail = "$ChannelThumbnail";

                    foreach ($ytvideothumb in $ytvideo.thumbnails) {
                        $ytvideothumbID = $ytvideothumb.id;
                        Write-to_Log -title "ytvideothumb" -content "$ytvideothumbID";
                        if ($ytvideothumbid -eq "avatar_uncropped") {
                            $ytchannel_thumbnail = $ytvideothumb.url;
                            Write-to_Log -title "ytvideothumb" -content "$ytchannel_thumbnail";
                            $endswiths0 = ($ytchannel_thumbnail -like "*=s0")
                            if ($endswiths0 -eq $true) {
                                Write-to_Log -title "endswiths0" -content "$endswiths0";
                                $ytchannel_thumbnail = $ytchannel_thumbnail.Substring(0,($ytchannel_thumbnail.length)-3);
                                Write-to_Log -title "ytvideothumb (ytchannel_thumbnail)" -content "$ytchannel_thumbnail";
                                $RSSData = Get-Content -LiteralPath "/data/rss/${RSSXML}.xml";
                                $RSSData = $RSSData.Replace("[PODCAST_IMAGE]","$ytchannel_thumbnail");
                                $RSSData = $RSSData.Replace("[PODCAST_DESCRIPTION]","$ytchannel_description");
                                Set-Content -LiteralPath "/data/rss/${RSSXML}.xml" -Value "$RSSData";
                                $JSON_Channel_File = $filename;
                                Write-to_Log -title "JSON_Channel_File" -content "$JSON_Channel_File";
                            }
                        } else {
                            $ytchannel_thumbnail = "$ChannelThumbnail";
                        }
                    }
                }
            }
        }
    }

    #
    # ─── CHECK FOR DUPLICATE RSS ITEM ───────────────────────────────────────────────
    #

    $RSS_Data = Get-Content -LiteralPath "/data/rss/${RSSXML}.xml";
    
    $objStartFolder = "${DownloadPath}/*.mp4";
    Write-to_Log -title "objStartFolder" -content "${objStartFolder}";
    $mediafiles = Get-ChildItem $objStartFolder;

    foreach ($file in $mediafiles) {
        $filename = $file.name;
        $filepath = $file.FullName;
        $VideoURL = [uri]::EscapeUriString($filename);

        Write-to_Log -title "Media File (MP4)" -content "${filename}";
        $jsonpath = $filepath.Replace(".mp4",".info.json");
        $compare = ($filename -ne $JSON_Channel_File);        

        if (Test-Path -LiteralPath $jsonpath) {
            Write-to_Log -title "GET JSON INFORMATION" -content "$($file.name)";
            Write-to_Log -title "JSON_Channel_File" -content "$JSON_Channel_File";
            Write-to_Log -title "compare" -content "$compare";
            $filename = $file.name;

            #
            # GET VALUES FROM JSON FILE
            #

            $json_data = Get-Content -LiteralPath "$jsonpath";
            $yt_videos = $json_data | ConvertFrom-Json;


            foreach ($ytvideo in $yt_videos)
            {
                # write-host "$($ytvideo.title), uploader: $($ytvideo.uploader)";
                $ytvideo_uid = $ytvideo.id;
                $ytvideo_title = $ytvideo.title;
                $ytvideo_thumbnail = $ytvideo.thumbnail;
                $ytvideo_description = $ytvideo.description;
                $ytvideo_uploader = $ytvideo.uploader;
                $ytvideo_uploader_url = $ytvideo.uploader_url;
                $ytvideo_channel_id = $ytvideo.channel_id;
                $ytvideo_channel_url = $ytvideo.channel_url;
                $ytvideo_duration = $ytvideo.duration;
                $ytvideo_webpage_url = $ytvideo.webpage_url;
                $ytvideo_filesize = $ytvideo.filesize_approx;
            }

            #
            # ─── SET VALUES IN DEFAULT RSS FILE ──────────────────────────────
            #

            $RSSData = "";
            $RSSData = Get-Content -LiteralPath "/data/rss/${RSSXML}.xml";
            if ($RSSData -like "*${ytvideo_uid}*") {
                Write-to_Log -title "Duplicate File" -content "TRUE";
            } else {
                Write-to_Log -title "Duplicate File" -content "FALSE";
                $RSSData = $RSSData.Replace("[ITEM_TITLE]","$ytvideo_title");
                $RSSData = $RSSData.Replace("[PODCAST_TITLE]","$ytvideo_uploader");
                $RSSData = $RSSData.Replace("[PODCAST_LINK]","$ytvideo_webpage_url");
                $RSSData = $RSSData.Replace("[PODCAST_IMAGE]","$ChannelThumbnail");
                $RSSData = $RSSData.Replace("[CHANNEL_LINK]","$ytvideo_channel_url");
                $RSSData = $RSSData.Replace("[PODCAST_DESCRIPTION]","$ytvideo_uploader");
                $ytvideo_description = $ytvideo_description.replace($([Environment]::NewLine),"<br />");
                $ytvideo_description = "<p>${ytvideo_description}</p>";
                # $CurrentDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"Australia/Melbourne");
                $CurrentDate = [DateTime]::Now;
                $guid = $CurrentDate;
                $guid = (Get-Date -Date "$CurrentDate" -Format 'dd/MM/yyyy hh:mm:ss:fff');
                $pubDate = (Get-Date -Date "$CurrentDate" -Format 'ddd, dd MMM yyyy hh:mm:ss +1000');
                $RSSItemsData = "<item>$([Environment]::NewLine)`t<title><![CDATA[${ytvideo_title}]]></title>$([Environment]::NewLine)`t<description><![CDATA[${ytvideo_description}]]></description>$([Environment]::NewLine)`t<link>${ytvideo_webpage_url}</link>$([Environment]::NewLine)`t<guid isPermaLink=`"false`">${ytvideo_webpage_url}</guid>$([Environment]::NewLine)`t<pubDate>${pubDate}</pubDate>$([Environment]::NewLine)`t<podcast:chapters url=`"[ITEM_CHAPTER_URL]`" type=`"application/json`"/>$([Environment]::NewLine)`t<itunes:subtitle><![CDATA[${ytvideo_uploader}]]></itunes:subtitle>$([Environment]::NewLine)`t<itunes:summary><![CDATA[${ytvideo_uploader}]]></itunes:summary>$([Environment]::NewLine)`t<itunes:author><![CDATA[${ytvideo_uploader}]]></itunes:author>$([Environment]::NewLine)`t<author><![CDATA[${ytvideo_uploader}]]></author>$([Environment]::NewLine)`t<itunes:image href=`"${ytvideo_thumbnail}`"/>$([Environment]::NewLine)`t<itunes:explicit>No</itunes:explicit>$([Environment]::NewLine)`t<itunes:keywords>youtube</itunes:keywords>$([Environment]::NewLine)`t<enclosure url=`"http://10.0.0.205:8383/podcasts/${ChannelID}/${VideoURL}`" type=`"video/mpeg`" length=`"${ytvideo_filesize}`"/>$([Environment]::NewLine)`t<podcast:person href=`"${ytvideo_channel_url}`" img=`"${ytvideo_thumbnail}`">${ytvideo_uploader}</podcast:person>$([Environment]::NewLine)`t<podcast:images srcset=`"${ytvideo_thumbnail} 2000w`"/>$([Environment]::NewLine)`t<itunes:duration>${ytvideo_duration}</itunes:duration>$([Environment]::NewLine)</item>$([Environment]::NewLine)<!-- INSERT_ITEMS_HERE -->$([Environment]::NewLine)";
                $RSSData = $RSSData.Replace("<!-- INSERT_ITEMS_HERE -->","$RSSItemsData");
                Set-Content -LiteralPath "/data/rss/${RSSXML}.xml" -Value "$RSSData";

                wget -O "/config/json/maxresdefault2.jpg" $ytvideo_thumbnail;
                $htmltext = "<html><body>${ytvideo_title}}<br /><br />--------------------------------------------<br /><br />${ytvideo_description}</body></html>";
                Out-File -FilePath "/config/json/pushovernotify2.txt" -InputObject $htmltext -Force;
                
                cat "/config/json/pushovernotify2.txt" | mutt -a "/config/json/maxresdefault2.jpg" -s "RSS Podcast Downloaded (${ChannelID})" -- mphfckm6ji@pomail.net;
            }
        }
    }

    find "/data/podcasts/${ChannelID}" -type f -ctime +5 -delete;
 }

function NotifyYouTube([string]$URL){
    yt-dlp -v -o "/config/json/videos/%(title)s_[%(id)s].%(ext)s" --skip-download --playlist-items 1,2,3,4,5 --write-info-json --no-write-playlist-metafiles --restrict-filenames --download-archive "/config/json/youtube-dl-notify.txt" --add-metadata --merge-output-format mp4 --format "best" --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue "${URL}";

    $objStartFolder = "/config/json/videos/*.json";
    $files = Get-ChildItem $objStartFolder;

    foreach ($file in $files) {
        $filename = $file.name;
        $filepath = $file.FullName
        $json_data = Get-Content -LiteralPath "$filepath";
        $yt_videos = $json_data | ConvertFrom-Json;

        foreach ($ytvideo in $yt_videos)
        {
            $ytvideodescription = $($ytvideo.description);
            $ytvideodescription = $ytvideodescription.replace($([Environment]::NewLine),"<br />");
            $ytvideodescription = "<p>${ytvideodescription}</p>";
            write-host "$($ytvideo.title), uploader: $($ytvideo.uploader)";
            $htmltext = "<html><body>$($ytvideo.title)<br />$($ytvideo.webpage_url)<br /><br />--------------------------------------------<br /><br />${ytvideodescription}</body></html>";
            Out-File -FilePath "/config/json/pushovernotify.txt" -InputObject $htmltext -Force;
            # wget -o "/config/json/maxresdefault.jpg" $($ytvideo.thumbnail);
            # cat "/config/json/pushovernotify.txt" | mutt mutt -a "/config/json/maxresdefault.jpg" -s "YouTube Video Uploaded ($($ytvideo.uploader))" -- dzfugv4ncm@pomail.net;

            wget -O "/config/json/maxresdefault.jpg" $($ytvideo.thumbnail);
            # cat "/config/json/pushovernotify.txt" | mutt -a "/config/json/maxresdefault.jpg" -s "YouTube Video Uploaded ($($ytvideo.uploader))" -- dzfugv4ncm@pomail.net;

            # Add-Content -LiteralPath "/config/json/youtube-dl-notify.txt" -Value "youtube $($ytvideo.id)";
            # Remove-Item -LiteralPath $filepath -Force;
            $ytvideouploader = $($ytvideo.uploader);
            $ytvideoid = $($ytvideo.id);
            $ytvideothumbnail = $($ytvideo.thumbnail);
        }
        cat "/config/json/pushovernotify.txt" | mutt -a "/config/json/maxresdefault.jpg" -s "YouTube Video Uploaded (${ytvideouploader})" -- dzfugv4ncm@pomail.net;

        Add-Content -LiteralPath "/config/json/youtube-dl-notify.txt" -Value "youtube ${ytvideoid}";
        Remove-Item -LiteralPath $filepath -Force;
    }
}

Try {
    <# ------------------ Global Variables ------------------ #>

    $LogFile_Date = (Get-Date -format "yyyy-MM-dd_HH-mm-ss");
    $ScriptName = Split-Path -leaf $PSCommandpath;
    $ScriptName = $ScriptName.Replace(".ps1","");
    $ScriptPath = Split-Path -Parent $PSCommandpath;
    # $LogFile = "\\FSE\digital\ROES\Command_Files\GIT_PROJECTS\RaceAtlas\${LogFile_Date}_${ScriptName}Log.log";
    $LogFile = "${ScriptPath}/Logs/${LogFile_Date}_${ScriptName} Log.log";
    $LogsFiles_ToDelete = (Get-Date).AddDays(-2);
    Start-Transcript -Path $LogFile;

    #
    # ─── START CODE ─────────────────────────────────────────────────────────────────
    #

        # To Watch YouTube Audio
        Create_RSS_v3 -ChannelID "To_Watch_Youtube_Audio" -RSSXML "ToDownloadAudioRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/playlist?list=PLNJTvO4HBij8Wux0m7v817mLoSbaj4l59" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-MYPLAYLIST.txt" -FileQuality "best" -ChannelThumbnail "https://yt3.ggpht.com/ytc/AMLnZu8TMglgWacF6opohoPRkRq24r0dPQbtamRjn0xD=s108-c-k-c0x00ffffff-no-rj";
        Create_RSS_v3 -ChannelID "To_Watch_Youtube_Audio" -RSSXML "ToDownloadAudioRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/playlist?list=PLNJTvO4HBij-As-16otoDkTMhSiQ0cyP_" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-MYPLAYLIST.txt" -FileQuality "best" -ChannelThumbnail "https://yt3.ggpht.com/ytc/AMLnZu8TMglgWacF6opohoPRkRq24r0dPQbtamRjn0xD=s108-c-k-c0x00ffffff-no-rj";
        Write-to_Log -title "Downloaded Video Files for" -content "To_Watch_Youtube_Audio";

        # To Watch Youtube
        Create_RSS_v3 -ChannelID "To_Watch_Youtube" -RSSXML "ToDownloadRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/playlist?list=PLNJTvO4HBij-9ZC97gjGR9JXObE_g_XDm" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-MYPLAYLIST.txt" -FileQuality "best" -ChannelThumbnail "https://yt3.ggpht.com/ytc/AMLnZu8TMglgWacF6opohoPRkRq24r0dPQbtamRjn0xD=s108-c-k-c0x00ffffff-no-rj";
        Write-to_Log -title "Downloaded Video Files for" -content "To_Watch_Youtube";

        # Biographics
        Create_RSS_v3 -ChannelID "Biographics" -RSSXML "BiographicsRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/channel/UClnDI2sdehVm1zm_LmUHsjQ/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "Biographics";

        # Dan Murrell
        Create_RSS_v3 -ChannelID "Dan_Murrell" -RSSXML "DanMurrellRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/channel/UCbiOAho0h23IMInURiESx1w/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "Dan_Murrell";

        # Emergency Awesome
        Create_RSS_v3 -ChannelID "Emergency_Awesome" -RSSXML "EmergencyAwesomeRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/channel/UCDiFRMQWpcp8_KD4vwIVicw/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "Emergency_Awesome";

        # ERB
        Create_RSS_v3 -ChannelID "ERB" -RSSXML "ERBRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/channel/UCMu5gPmKp5av0QCAajKTMhw/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "ERB";

        # FilmJoy
        Create_RSS_v3 -ChannelID "FilmJoy" -RSSXML "FilmJoyRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/channel/UCEtB-nx5ngoNJWEzYa-yXBg/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "FilmJoy";

        # Honest Trailers
        Create_RSS_v3 -ChannelID "Honest_Trailers" -RSSXML "HonestTrailersRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/playlist?list=PL86F4D497FD3CACCE" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "Honest_Trailers";

        # PS Access
        Create_RSS_v3 -ChannelID "PS_Access" -RSSXML "PSAccessRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/user/PlayStationAccess/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "PS_Access";

        # Hot Ones
        Create_RSS_v3 -ChannelID "Hot_Ones" -RSSXML "HotOnesRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/playlist?list=PLAzrgbu8gEMIIK3r4Se1dOZWSZzUSadfZ" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "https://yt3.ggpht.com/ytc/AMLnZu8DeRF1AWLlRnKZmQQWlrC6mCzdpZMnnJWbAN2tPA=s88-c-k-c0x00ffffff-no-rj";
        Write-to_Log -title "Downloaded Video Files for" -content "Hot_Ones";

        # MediaWatch
        Create_RSS_v3 -ChannelID "MediaWatch" -RSSXML "MediaWatchRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/playlist?list=PLDTPrMoGHssBtV3J7BBLZAuY9U5UX92mt" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "https://pbs.twimg.com/profile_images/1587643154022666241/TuT-jx-f_400x400.jpg";
        Write-to_Log -title "Downloaded Video Files for" -content "MediaWatch";

        # MegaProjects
        Create_RSS_v3 -ChannelID "MegaProjects" -RSSXML "MegaProjectsRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/channel/UC0woBco6Dgcxt0h8SwyyOmw/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "MegaProjects";

        # PDS
        Create_RSS_v3 -ChannelID "PDS" -RSSXML "PDSRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/channel/UClFSU9_bUb4Rc6OYfTt5SPw/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "PDS";

        # Shaqtin
        Create_RSS_v3 -ChannelID "Shaqtin" -RSSXML "ShaqtinRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/playlist?list=PLU6BYY1Lu_feVbuZEscpd6xT32zCrVrev" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "https://www.opencourt-basketball.com/wp-content/uploads/2016/06/saf.jpg";
        Write-to_Log -title "Downloaded Video Files for" -content "Shaqtin";

        # thejuicemedia
        Create_RSS_v3 -ChannelID "thejuicemedia" -RSSXML "thejuicemediaRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/channel/UCKRw8GAAtm27q4R3Q0kst_g/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "thejuicemedia";

        # Inside Games
        Create_RSS_v3 -ChannelID "Inside_Games" -RSSXML "InsideGamesRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/channel/UCFHQlasvjQ0JMOHoKOz4c0g/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "Inside_Games";

        # Sideprojects
        Create_RSS_v3 -ChannelID "Sideprojects" -RSSXML "SideprojectsRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/c/Sideprojects/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "Sideprojects";

        # Today I Found Out
        Create_RSS_v3 -ChannelID "Today_I_Found_Out" -RSSXML "TodayIFoundOutRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/c/Todayifoundout-official" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "Today_I_Found_Out";

        # TheWestReport
        Create_RSS_v3 -ChannelID "TheWestReport" -RSSXML "TheWestReportRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/c/TheWestReport" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "TheWestReport";

        # CinemaTherapy
        Create_RSS_v3 -ChannelID "CinemaTherapy" -RSSXML "CinemaTherapyRSS" -MediaFolder "/data/podcasts/" -YouTubeURL "https://www.youtube.com/@CinemaTherapyShow/videos" -FileFormat "mp4" -DownloadArchive "/config/youtube-dl-archive-ALL.txt" -FileQuality "best" -ChannelThumbnail "";
        Write-to_Log -title "Downloaded Video Files for" -content "CinemaTherapy";

    #
    # ─── ADD TO RSS FILES ───────────────────────────────────────────────────────────
    #

    # Create_RSS -ChannelID "To_Watch_Youtube_Audio" -RSSXML "ToDownloadAudioRSS" -MediaFolder "/data/podcasts/";

    #
    # ─── NOTIFYYOUTUBE ──────────────────────────────────────────────────────────────
    #

    NotifyYouTube -URL "https://www.youtube.com/user/PlayStationAccess/streams";
    NotifyYouTube -URL "https://www.youtube.com/c/ChilledChaosGAME/videos";
    NotifyYouTube -URL "https://www.youtube.com/@PhilosophyInsights/videos";
    NotifyYouTube -URL "https://www.youtube.com/@PlayStationAU/videos";
    NotifyYouTube -URL "https://www.youtube.com/@ReasonTV/videos";
    NotifyYouTube -URL "https://www.youtube.com/c/JordanPetersonVideos/videos";
    NotifyYouTube -URL "https://www.youtube.com/@LinusTechTips/videos";
    NotifyYouTube -URL "https://www.youtube.com/c/NateTheLawyer/videos";
    NotifyYouTube -URL "https://www.youtube.com/c/HoegLaw/videos";
    NotifyYouTube -URL "https://www.youtube.com/c/BruceGreene/videos";
    NotifyYouTube -URL "https://www.youtube.com/c/LawrenceSonntag/videos";
    NotifyYouTube -URL "https://www.youtube.com/c/Drivetribe/videos";
    NotifyYouTube -URL "https://www.youtube.com/@ServeTheHomeVideo/videos";
    NotifyYouTube -URL "https://www.youtube.com/@JonSandman/videos";
    NotifyYouTube -URL "https://www.youtube.com/@HogwartsLegacy/videos";
    Write-to_Log -title "NotifyYouTube" -content "Finished";

    # 
    # ─── END CODE ───────────────────────────────────────────────────────────────────
    #
    $ListLogsFiles = Get-ChildItem -Path "${ScriptPath}/Logs/*_${ScriptName} Log.log"  | Where-Object { $_.CreationTime -le $LogsFiles_ToDelete };
    foreach ($LogItem in $ListLogsFiles) {
        Write-to_Log -title "Cleanup Log Files" -content "Delete File: ${LogItem}";
        Remove-Item -Path $LogItem -Force;
    }
    Stop-Transcript;

        
}
Catch {
    $ScriptName = $MyInvocation.InvocationName;
    $ErrMsgCategoryInfo = $_.CategoryInfo;
    $ErrMsgTargetObject = $_.TargetObject;
    $ErrMsgErrorDetails = $_.ErrorDetails;
    $ErrMsgException = $_.Exception;
    $ErrMsgInvocationInfo = $_.InvocationInfo;
    $ErrMsgScriptStackTrace = $_.ScriptStackTrace;
    Write-to_Log -title "ERROR" -content "***********************************     ERROR     ***********************************";
    Write-to_Log -title "CategoryInfo" -content "$ErrMsgCategoryInfo";
    Write-to_Log -title "TargetObject" -content "$ErrMsgTargetObject";
    Write-to_Log -title "InvocationInfo" -content "$ErrMsgInvocationInfo";
    Write-to_Log -title "ScriptStackTrace" -content "$ErrMsgScriptStackTrace";
    Write-to_Log -title "ErrorDetails" -content "$ErrMsgErrorDetails";
    Write-to_Log -title "Exception" -content "$ErrMsgException";
    $ErrorBody = "***********************************     ERROR     ***********************************$([Environment]::NewLine)$([Environment]::NewLine)CategoryInfo: $(ErrMsgCategoryInfo)$([Environment]::NewLine)TargetObject: $(ErrMsgTargetObject)$([Environment]::NewLine)InvocationInfo: $(ErrMsgInvocationInfo)$([Environment]::NewLine)--------------------$([Environment]::NewLine)ScriptStackTrace: $(ErrMsgScriptStackTrace)$([Environment]::NewLine)--------------------$([Environment]::NewLine)ErrorDetails: $(ErrMsgErrorDetails)$([Environment]::NewLine)--------------------$([Environment]::NewLine)Exception: $(ErrMsgException)";
    Stop-Transcript;
    # Send-ToEmail-Error  -email "roes@hcpro.com.au" -subject "Script Error (${ScriptName})" -body "$ErrorBody" -AttFile "$LogFile";
    # $htmltext = "From: a.wirthy@gmail.com$([Environment]::NewLine)To: a.wirthy@gmail.com$([Environment]::NewLine)Subject: Script Error ($(ScriptName))$([Environment]::NewLine)${ErrorBody}";
    $htmltext = "${ErrorBody}";
    Out-File -FilePath "/config/scripterroremail.txt" -InputObject $htmltext;
    cat "/config/scripterroremail.txt" | mutt -a "$(LogFile)" -s "Script Error (${ScriptName})" -- a.wirthy@gmail.com;
    Break
}