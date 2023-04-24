# RUN /mnt/pve/NFS_1TB/Python$ python3 /mnt/pve/NFS_1TB/Python/Read_XML.py
from pathlib import Path
from xml.dom import minidom
import time
from xml.parsers.expat import ExpatError
import os
import subprocess
import json
import requests
import feedparser
from email_validator import validate_email, EmailNotValidError
# from email_validator import EmailNotValidError
# from email_validator import EmailSynaxError
# from email_validator import EmailUndeliverableError

# def Write_to_Log(logContent):
#     x = datetime.datetime.now()
#     print(x.strftime("%X")) 
#     # print(x)

def DeleteOldFiles(NumberofDays,FolderPath):        
    # N is the number of days for which
    # we have to check whether the file
    # is older than the specified days or not
    # N = 2
    N = NumberofDays
    # os.chdir("/data/podcasts/CinemaTherapy/")
    os.chdir(FolderPath)
    list_of_files = os.listdir()
    current_time = time.time()

    # "day" is the number of seconds in a day
    day = 86400

    # loop over all the files
    for i in list_of_files:
        # get the location of the file
        # file_location = os.path.join(os.getcwd(), i)
        file_location = FolderPath + i
        current_time = time.time()
        print("Current Time: " + str(current_time))
        # file_time is the time when the file is modified
        print(file_location)

        pathname, extension = os.path.splitext(file_location)
        print("extension: " + str(extension))
        if (extension == ".description"):
            file_desc = pathname + ".description"
            file_mp4 = pathname + ".mp4"
            file_mp3 = pathname + ".mp3"
            file_json = pathname + ".json.info"
            file_time = os.stat(file_location).st_mtime

            print("file_desc: " + file_desc)
            print("file_mp4: " + file_mp4)
            print("file_mp3: " + file_mp3)
            print("file_json: " + file_json)

            if os.path.isfile(file_desc):
                file_time = os.stat(file_desc).st_mtime
                print("file_time: " + str(file_time))
                if(file_time < current_time - day*N):
                    if os.path.isfile(file_desc):
                        print(f" Delete : " + file_desc)
                        os.remove(file_desc)
                    if os.path.isfile(file_mp3):
                        print(f" Delete : " + file_mp3)
                        os.remove(file_mp3)
                    if os.path.isfile(file_mp4):
                        print(f" Delete : " + file_mp4)
                        os.remove(file_mp4)
                    if os.path.isfile(file_json):
                        print(f" Delete : " + file_json)
                        os.remove(file_json)

def NotifyPushover(AppToken,nTitle,nBody,pThumbnail):
    # wget -O "/config/json/maxresdefault2.jpg" $ytvideo_thumbnail;
    # $htmltext = "<html><body>${ytvideo_title}}<br /><br />--------------------------------------------<br /><br />${ytvideo_description}</body></html>";
    # Out-File -FilePath "/config/json/pushovernotify2.txt" -InputObject $htmltext -Force;
    
    # cat "/config/json/pushovernotify2.txt" | mutt -a "/config/json/maxresdefault2.jpg" -s "RSS Podcast Downloaded (${ChannelID})" -- mphfckm6ji@pomail.net;
    try:
        print ('------------------      START NotifyPushover\n')
        bashcmd = 'wget -O /config/maxresdefault.jpg ' + pThumbnail
        print("bashcmd: " + bashcmd)
        process = subprocess.Popen(bashcmd.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()

        APPLICATION_TOKEN = AppToken
        USER_TOKEN = "ZLzrC79W0yAeoj5f4Jz0P3EZbHJKAB"
        url = 'https://api.pushover.net/1/messages.json'
        my_pushover_request = {'token': APPLICATION_TOKEN, 'user': USER_TOKEN,
                    'title': nTitle, 'message': nBody, 'html': '1'}
        req = requests.post(url, data=my_pushover_request, files={"attachment":open("/config/maxresdefault.jpg","rb")})
        print("Pushover Status: " + str(req.status_code))
        print ('------------------      END NotifyPushover\n')
    except Exception as err:
        print ('------------------      START NotifyPushover ERROR\n')
        print (err)
        print ('\n------------------      END NotifyPushover ERROR')

def NotifyTwitch(pName, pYouTubeURL):

    try:
        print ('------------------      START NotifyTwitch\n')
        bashcmd = "yt-dlp -v -o " + jsonMediaFolder_Twitch + "/%(id)s.%(ext)s --skip-download --write-info-json --no-write-playlist-metafiles --restrict-filenames --download-archive " + Twitch_DownloadArchive + " --add-metadata --merge-output-format mp4 --format best --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue " + pYouTubeURL
        # bashcmd = "yt-dlp -v -o " + jsonMediaFolder_YouTube + "/%(id)s.%(ext)s --skip-download --playlist-items 1,2,3,4,5 --write-info-json --no-write-playlist-metafiles --restrict-filenames --download-archive /config/json/youtube-dl-notify.txt --add-metadata --merge-output-format mp4 --format best --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue " + pYouTubeURL

        process = subprocess.Popen(bashcmd.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()

        print("output: " + str(output))
        print("error: " + str(error))

        directory = os.fsencode(jsonMediaFolder_Twitch)
                
        for file in os.listdir(directory):
            filename = os.fsdecode(file)
            filename_noext = ""
            filename_mediafile = ""
            filename_json = ""
            if filename.endswith(".json"): 
                print("Notify Filename: " + filename)

                f = open(jsonMediaFolder_Twitch + filename)
                data = json.load(f)
                
                # ~~~~~~~~~~~~~ Get JSON Data ~~~~~~~~~~~~~ #
                ytvideo_uid = data['id']
                ytvideo_title = data['title']
                # ytvideo_description = data['description']
                ytvideo_uploader = data['uploader']
                ytvideo_webpage_url = data['webpage_url']
                ytvideo_thumbnail = data['thumbnail']

                print("ytvideo_uid: " + ytvideo_uid)
                print("ytvideo_title: " + ytvideo_title)
                print("ytvideo_uploader: " + ytvideo_uploader)
                # print("ytvideo_description: " + ytvideo_description)
                print("ytvideo_thumbnail: " + ytvideo_thumbnail)

                # ~~~~~~~~~~~~~~ Get Chapters ~~~~~~~~~~~~~ #

                for chapters in data['chapters']:
                    chaptersjson = str(chapters).replace("'",'"')
                    # print('thumbs json: ' + thumbsjson)
                    chaptersdata = json.loads(chaptersjson)

                    ytvideo_chapter_title = chaptersdata['title']
                    print("chapter: " + ytvideo_chapter_title)

                f.close()

                # ~~~~~~~~~~~~~ Add to archive ~~~~~~~~~~~~ #

                archive = open(Twitch_DownloadArchive, "a")
                archive.write("youtube " + ytvideo_uid + "\n")
                archive.close()
                os.remove(jsonMediaFolder_Twitch + "/" + ytvideo_uid + ".info.json") 

                # ======================================================== #
                # ==================== Notify Pushover =================== #
                # ======================================================== #

                # print("NotifyPushover: " + "Twitch Video Uploaded (" + pName + ") - " + ytvideo_title)
                # NotifyPushover("aqug9r3zj8zw5aq17gu6ozd5gk55sd","Twitch Video Uploaded (" + pName + ")","<html><body>" + ytvideo_title + "<br /><br />" + ytvideo_webpage_url + "</body></html>",ytvideo_thumbnail)

        # print('Downloaded Video Files for ' + pName)
        print ('------------------      END NotifyTwitch\n')
    except Exception as err:
        print ('------------------      START NotifyTwitch ERROR\n')
        print (err)
        print ('\n------------------      END NotifyTwitch ERROR')

def NotifyYouTube(pName, pYouTubeURL):
    # print("NotifyYouTube")

    #              yt-dlp -v -o "/config/json/videos/%(title)s_[%(id)s].%(ext)s" --skip-download --playlist-items 1,2,3,4,5,3,4,5 --write-info-json --no-write-playlist-metafiles --restrict-filenames --download-archive "/config/json/youtube-dl-notify.txt" --add-metadata --merge-output-format mp4 --format "best" --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue "${URL}";

    try:
        print ('------------------      START NotifyYouTube\n')
        bashcmd = "yt-dlp -v -o " + jsonMediaFolder_YouTube + "/%(id)s.%(ext)s --skip-download --playlist-items 1,2,3,4,5 --write-info-json --no-write-playlist-metafiles --restrict-filenames --download-archive /config/json/youtube-dl-notify.txt --add-metadata --merge-output-format mp4 --format best --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue " + pYouTubeURL
        # bashcmd = "yt-dlp -v -o " + jsonMediaFolder_YouTube + "/%(id)s.%(ext)s --skip-download --playlist-items 1,2,3,4,5 --write-info-json --no-write-playlist-metafiles --restrict-filenames --download-archive /config/json/youtube-dl-notify.txt --add-metadata --merge-output-format mp4 --format best --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue " + pYouTubeURL

        process = subprocess.Popen(bashcmd.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()

        print("output: " + str(output))
        print("error: " + str(error))

        directory = os.fsencode(jsonMediaFolder_YouTube)
                
        for file in os.listdir(directory):
            filename = os.fsdecode(file)
            filename_noext = ""
            filename_mediafile = ""
            filename_json = ""
            if filename.endswith(".json"): 
                print("Notify Filename: " + filename)

                f = open(jsonMediaFolder_YouTube + filename)
                data = json.load(f)
                
                # ~~~~~~~~~~~~~ Get JSON Data ~~~~~~~~~~~~~ #
                ytvideo_uid = data['id']
                ytvideo_title = data['title']
                ytvideo_description = data['description']
                ytvideo_uploader = data['uploader']
                # ytvideo_uploader_id = data['uploader_id']
                # ytvideo_uploader_url = data['uploader_url']
                # ytvideo_channel_id = data['channel_id']
                # ytvideo_channel_url = data['channel_url']
                # ytvideo_duration = 0
                ytvideo_webpage_url = data['webpage_url']
                # ytvideo_filesize = 0
                ytvideo_thumbnail = data['thumbnail']

                print("ytvideo_uid: " + ytvideo_uid)
                print("ytvideo_title: " + ytvideo_title)
                print("ytvideo_uploader: " + ytvideo_uploader)
                print("ytvideo_description: " + ytvideo_description)
                print("ytvideo_thumbnail: " + ytvideo_thumbnail)

                f.close()

                # ~~~~~~~~~~~~~ Add to archive ~~~~~~~~~~~~ #

                archive = open("/config/json/youtube-dl-notify.txt", "a")
                archive.write("youtube " + ytvideo_uid + "\n")
                archive.close()
                os.remove(jsonMediaFolder_YouTube + "/" + ytvideo_uid + ".info.json") 

                # htmltext = "<html><body>$($ytvideo.title)<br />$($ytvideo.webpage_url)<br /><br />--------------------------------------------<br /><br />${ytvideodescription}</body></html>";

                # ======================================================== #
                # ==================== Notify Pushover =================== #
                # ======================================================== #

                print("NotifyPushover: " + "YouTube Video Uploaded (" + pName + ") - " + ytvideo_title)
                NotifyPushover("aba5oiapuej79it7yy3hvzo5aqusnj","YouTube Video Uploaded (" + pName + ")","<html><body>" + ytvideo_title + "<br /><br />" + ytvideo_webpage_url + "<br /><br />--------------------------------------------<br /><br />" + ytvideo_description + "</body></html>",ytvideo_thumbnail)

        # print('Downloaded Video Files for ' + pName)
        print ('------------------      END NotifyYouTube\n')
    except Exception as err:
        print ('------------------      START NotifyYouTube ERROR\n')
        print (err)
        print ('\n------------------      END NotifyYouTube ERROR')

def Run_YTDLP(sMediaFolder, pName, pChannelID, pFileFormat, pDownloadArchive, pFileQuality, pChannelThumbnail, pYouTubeURL):
    print('Run_YTDLP')
    error = ''

    try:
        print ('------------------      START YT-DLP\n')
        # ======================================================== #
        # ============== Download Channel JSON Only ============== #
        # ======================================================== #

        bashcmd3 = "yt-dlp -v -o " + sMediaFolder + pChannelID + "/" + pChannelID + ".%(ext)s --write-info-json --playlist-items 0 --restrict-filenames --add-metadata --merge-output-format " + pFileFormat + " --format " + pFileQuality + " --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue " + pYouTubeURL
        # bashcmd = "yt-dlp -v -o '" + sMediaFolder + pChannelID + "/%(id)s.%(ext)s' --write-info-json --external-downloader aria2c --external-downloader-args '-c -j 10 -x 10 -s 10 -k 1M' --playlist-items 1,2,3,4,5,3,4,5 --restrict-filenames --download-archive '" + pDownloadArchive + "' --add-metadata --merge-output-format " + pFileFormat + " --format " + pFileQuality + " --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue --write-description " + pYouTubeURL
        # print(bashcmd)

        process3 = subprocess.Popen(bashcmd3.split(), stdout=subprocess.PIPE)
        output3, error3 = process3.communicate()

        print("output: " + str(output3))
        print("error: " + str(error3))

        # ======================================================== #
        # ============== Download Videos with yt-dlp ============= #
        # ======================================================== #

        bashcmd = "yt-dlp -v -o " + sMediaFolder + pChannelID + "/%(id)s.%(ext)s --write-info-json --no-write-playlist-metafiles --playlist-items 1,2,3,4,5 --restrict-filenames --download-archive " + pDownloadArchive + " --add-metadata --merge-output-format " + pFileFormat + " --format " + pFileQuality + " --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue --write-description " + pYouTubeURL
        # bashcmd = "yt-dlp -v -o '" + sMediaFolder + pChannelID + "/%(id)s.%(ext)s' --write-info-json --external-downloader aria2c --external-downloader-args '-c -j 10 -x 10 -s 10 -k 1M' --playlist-items 1,2,3,4,5,3,4,5 --restrict-filenames --download-archive '" + pDownloadArchive + "' --add-metadata --merge-output-format " + pFileFormat + " --format " + pFileQuality + " --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue --write-description " + pYouTubeURL
        # print(bashcmd)

        process = subprocess.Popen(bashcmd.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()

        print("output: " + str(output))
        print("error: " + str(error))

        print('Downloaded Video Files for ' + pName)
        print ('------------------      END YT-DLP\n')
    except Exception as err:
        print ('------------------      START YT-DLP ERROR\n')
        print (err)
        print ('\n------------------      END YT-DLP ERROR')

    if error == None:
        try:
            print("List Files")
            
            directory = os.fsencode(sMediaFolder + pChannelID)
                
            for file in os.listdir(directory):
                filename = os.fsdecode(file)
                filename_noext = ""
                filename_mediafile = ""
                filename_json = ""
                if filename.endswith(".description"): 
                    try:
                        pathname, extension = os.path.splitext(filename)
                        filename = pathname.split('/')
                        filename_noext = filename[-1]
                        
                        print("filename (no ext)" + filename_noext)
                    except:
                        print ('------------------      START GET EXT ERROR\n')
                        print (err)
                        print ('\n------------------      END GET EXT ERROR')

                    filename_json = sMediaFolder + pChannelID + "/" + filename_noext + ".info.json"
                    filename_mp3 = sMediaFolder + pChannelID + "/" + filename_noext + ".mp3"
                    filename_mp4 = sMediaFolder + pChannelID + "/" + filename_noext + ".mp4"

                    print("filename_json: " + filename_json)
                    print("filename_mp3: " + filename_mp3)
                    print("filename_mp4: " + filename_mp4)

                    filename_json_isfile = False
                    filename_mp3_isfile = False
                    filename_mp4_isfile = False

                    if os.path.isfile(filename_json):
                        print('The JSON file is present.')
                        filename_json_isfile = True
                    if os.path.isfile(filename_mp3):
                        print('The MP3 file is present.')
                        filename_mp3_isfile = True
                        filename_ext = filename_noext + ".mp3"
                    if os.path.isfile(filename_mp4):
                        print('The MP4 file is present.')
                        filename_mp4_isfile = True
                        filename_ext = filename_noext + ".mp4"

                    ytvideo_uid = ""
                    ytvideo_title = ""
                    ytvideo_thumbnail = ""
                    ytvideo_description = ""
                    ytvideo_uploader = ""
                    ytvideo_uploader_url = ""
                    ytvideo_channel_id = ""
                    ytvideo_channel_url = ""
                    ytvideo_duration = ""
                    ytvideo_webpage_url = ""
                    ytvideo_filesize = ""

                    if (filename_json_isfile == True and filename_mp4_isfile == True):
                        # print("ADD FILE TO RSS FEED: " + filename_mp4)
                        # print("Read JSON File")
                        f = open(filename_json)
                        data = json.load(f)
                        # print(data['id'])
                        
                        # Iterating through the json
                        # list
                        # for i in data['id']:
                        #     print(i)
                        
                        # ~~~~~~~~~~~~~ Get JSON Data ~~~~~~~~~~~~~ #
                        ytvideo_uid = data['id']
                        ytvideo_title = data['title']
                        ytvideo_description = data['description']
                        ytvideo_uploader = data['uploader']
                        ytvideo_uploader_id = data['uploader_id']
                        ytvideo_uploader_url = data['uploader_url']
                        ytvideo_channel_id = data['channel_id']
                        ytvideo_channel_url = data['channel_url']
                        ytvideo_duration = 0
                        ytvideo_webpage_url = data['webpage_url']
                        ytvideo_filesize = 0
                        # ytvideo_thumbnail = data['thumbnail']
                        ytvideo_thumbnail = "https://i.ytimg.com/vi_webp/" + ytvideo_uid + "/maxresdefault.webp"
                        # https://i.ytimg.com/vi_webp/wocnSQ4fsiI/maxresdefault.webp
                        # https://i.ytimg.com/vi/wocnSQ4fsiI/maxresdefault.jpg

                        print("ytvideo_uid: " + ytvideo_uid)
                        print("ytvideo_title: " + ytvideo_title)
                        print("ytvideo_uploader: " + ytvideo_uploader)
                        print("ytvideo_uploader_id: " + ytvideo_uploader_id)
                        print("ytvideo_uploader_url: " + ytvideo_uploader_url)
                        print("ytvideo_channel_id: " + ytvideo_channel_id)
                        print("ytvideo_channel_url: " + ytvideo_channel_url)
                        print("ytvideo_webpage_url: " + ytvideo_webpage_url)

                        # print('ytvideo_duration: ' + str(ytvideo_duration))
                        print ('\n------------------      Item (' + ytvideo_uid + ')')

                        # Closing file
                        f.close()

                        # ======================================================== #
                        # ================ Get Channel Information =============== #
                        # ======================================================== #
                        channel_filename_json = sMediaFolder + pChannelID + "/" + pChannelID + ".info.json"
                        channelf = open(channel_filename_json)
                        channeldata = json.load(channelf)
                        ytvideo_channel_desc = channeldata['description']
                        ytvideo_channel_image = ''
                        # print("----------------------   Thumbnails")
                        # print(channeldata['thumbnails'])
                        for thumbs in channeldata['thumbnails']:
                            thumbsjson = str(thumbs).replace("'",'"')
                            # print('thumbs json: ' + thumbsjson)
                            thumbdata = json.loads(thumbsjson)

                            if thumbdata['id'] == "avatar_uncropped":
                                # print("id: " + thumbdata['id'])
                                # print("url: " + thumbdata['url'])
                                ytvideo_channel_image = thumbdata['url']
                            # print("-------- THUMB")
                        # print("----------------------")
                        if pChannelThumbnail == "":
                            pChannelThumbnail = ytvideo_channel_image
                        print("Channel Thumbnail: " + ytvideo_channel_image)
                        channelf.close



                        rssPathFile = rssPath + pChannelID + 'RSS.xml'
                        print("RSS File Path: " + rssPathFile)
                        if os.path.isfile(rssPathFile):
                            print('The RSS file is present. File: ' + rssPathFile)
                            rssPathFile_isfile = True

                            with open(rssPathFile, 'r') as rsstemplate:
                                RSSData = rsstemplate.readlines()
                                strRSSData = ''.join(RSSData)

                            # ======================================================== #
                            # =============== Add Items to Existing XML ============== #
                            # ======================================================== #

                            if ytvideo_uid in strRSSData:
                                print("Item (" + ytvideo_uid + ") already in RSS file")
                            else:
                                print("Item (" + ytvideo_uid + ") not in RSS file")
                                pubDate = time.strftime('%d/%m/%Y %H:%M:%S' + ' +1000')
                                # print("pubDate: " + pubDate)
                                RSSItemsData = '\t\t<item>\n\t\t\t<title><![CDATA[' + ytvideo_title + ']]></title>\n\t\t\t<description><![CDATA[' + ytvideo_description + ']]></description>\n\t\t\t<link>' + ytvideo_webpage_url + '</link>\n\t\t\t<guid isPermaLink="false">' + ytvideo_webpage_url + '</guid>\n\t\t\t<pubDate>' + str(pubDate) + '</pubDate>\n\t\t\t<podcast:chapters url="[ITEM_CHAPTER_URL]" type="application/json"/>\n\t\t\t<itunes:subtitle><![CDATA[' + ytvideo_uploader + ']]></itunes:subtitle>\n\t\t\t<itunes:summary><![CDATA[' + ytvideo_uploader + ']]></itunes:summary>\n\t\t\t<itunes:author><![CDATA[' + ytvideo_uploader + ']]></itunes:author>\n\t\t\t<author><![CDATA[' + ytvideo_uploader + ']]></author>\n\t\t\t<itunes:image href="' + ytvideo_thumbnail + '"/>\n\t\t\t<itunes:explicit>No</itunes:explicit>\n\t\t\t<itunes:keywords>youtube</itunes:keywords>\n\t\t\t<enclosure url="' + httpHost + '/podcasts/' + pChannelID + '/' + filename_ext + '" type="video/mpeg" length="' + str(ytvideo_filesize) + '"/>\n\t\t\t<podcast:person href="' + ytvideo_channel_url + '" img="' + ytvideo_thumbnail + '">' + ytvideo_uploader + '</podcast:person>\n\t\t\t<podcast:images srcset="' + ytvideo_thumbnail + ' 2000w"/>\n\t\t\t<itunes:duration>' + str(ytvideo_duration) + '</itunes:duration>\n\t\t</item>\n<!-- INSERT_ITEMS_HERE -->'
                                strRSSData = strRSSData.replace("<!-- INSERT_ITEMS_HERE -->",RSSItemsData)
                                rss = open(rssPath + pChannelID + "RSS.xml", "w")
                                rss.write(strRSSData)
                                rss.close()
                                print("Item added to RSS file: " + ytvideo_uid)

                                # ======================================================== #
                                # ==================== Notify Pushover =================== #
                                # ======================================================== #

                                NotifyPushover("apb75jkyb1iegxzp4styr5tgidq3fg","RSS Podcast Downloaded (" + pName + ")","<html><body>" + ytvideo_title + "<br /><br />--------------------------------------------<br /><br />" + ytvideo_description + "</body></html>",ytvideo_thumbnail)
                        else:
                            print('The RSS file is not present. File: ' + rssPathFile)
                            rssPathFile_isfile = False

                            # ======================================================== #
                            # ================== Create New RSS File ================= #
                            # ======================================================== #

                            with open(rssTemplatePath, 'r') as rsstemplate:
                                RSSData = rsstemplate.readlines()
                                strRSSData = ''.join(RSSData)
                            strRSSData = strRSSData.replace("[CHANNEL_LINK]",ytvideo_channel_url)
                            strRSSData = strRSSData.replace("[PODCAST_TITLE]",pName)
                            strRSSData = strRSSData.replace("[PODCAST_IMAGE]",ytvideo_channel_image)
                            strRSSData = strRSSData.replace("[PODCAST_DESCRIPTION]",ytvideo_channel_desc)

                            # ======================================================== #
                            # ================= Add Items to New XML ================= #
                            # ======================================================== #

                            pubDate = time.strftime('%d/%m/%Y %H:%M:%S' + ' +1000')
                            # print("pubDate: " + pubDate)
                            RSSItemsData = '\t\t<item>\n\t\t\t<title><![CDATA[' + ytvideo_title + ']]></title>\n\t\t\t<description><![CDATA[' + ytvideo_description + ']]></description>\n\t\t\t<link>' + ytvideo_webpage_url + '</link>\n\t\t\t<guid isPermaLink="false">' + ytvideo_webpage_url + '</guid>\n\t\t\t<pubDate>' + str(pubDate) + '</pubDate>\n\t\t\t<podcast:chapters url="[ITEM_CHAPTER_URL]" type="application/json"/>\n\t\t\t<itunes:subtitle><![CDATA[' + ytvideo_uploader + ']]></itunes:subtitle>\n\t\t\t<itunes:summary><![CDATA[' + ytvideo_uploader + ']]></itunes:summary>\n\t\t\t<itunes:author><![CDATA[' + ytvideo_uploader + ']]></itunes:author>\n\t\t\t<author><![CDATA[' + ytvideo_uploader + ']]></author>\n\t\t\t<itunes:image href="' + ytvideo_thumbnail + '"/>\n\t\t\t<itunes:explicit>No</itunes:explicit>\n\t\t\t<itunes:keywords>youtube</itunes:keywords>\n\t\t\t<enclosure url="' + httpHost + '/podcasts/' + pChannelID + '/' + filename_ext + '" type="video/mpeg" length="' + str(ytvideo_filesize) + '"/>\n\t\t\t<podcast:person href="' + ytvideo_channel_url + '" img="' + ytvideo_thumbnail + '">' + ytvideo_uploader + '</podcast:person>\n\t\t\t<podcast:images srcset="' + ytvideo_thumbnail + '2000w"/>\n\t\t\t<itunes:duration>' + str(ytvideo_duration) + '</itunes:duration>\n\t\t</item>\n<!-- INSERT_ITEMS_HERE -->'
                            strRSSData = strRSSData.replace("<!-- INSERT_ITEMS_HERE -->",RSSItemsData)
                            print("Item added to RSS file: " + ytvideo_uid)

                            # ======================================================== #
                            # ==================== Notify Pushover =================== #
                            # ======================================================== #

                            NotifyPushover("apb75jkyb1iegxzp4styr5tgidq3fg","RSS Podcast Downloaded (" + pName + ")","<html><body>" + ytvideo_title + "<br /><br />--------------------------------------------<br /><br />" + ytvideo_description + "</body></html>",ytvideo_thumbnail)

                            # ======================================================== #
                            # ==================== Write XML File ==================== #
                            # ======================================================== #

                            # print("----------------------")
                            # print(strRSSData)
                            # print("----------------------")

                            rss = open(rssPath + pChannelID + "RSS.xml", "w")
                            # rss = open("/mnt/pve/NFS_1TB/Python/" + pChannelID + "RSS.xml", "w")
                            rss.write(strRSSData)
                            rss.close()
                            print ('\n------------------      END Item (' + ytvideo_uid + ')')
                    continue
                else:
                    continue
        except Exception as err:
            print ('------------------      START GET FILES ERROR\n')
            print (err)
            print (err.__annotations__)
            print (err.with_traceback)
            print ('\n------------------      END GET FILES ERROR')
    else:
        # print("YT-DLP ERROR")
        print ('------------------      START YT-DLP ERROR\n')
        print (err)
        print (err.__annotations__)
        print (err.with_traceback)
        print ('\n------------------      END YT-DLP ERROR')

def Run_RSS_YTDLP(sMediaFolder, pName, pChannelID, pFileFormat, pDownloadArchive, pFileQuality, pChannelThumbnail, Podcast_RSSURL):
    print('Run_RSS_YTDLP')
    error = ''

    try:
        print ('------------------      START Read_RSS\n')
        # ======================================================== #
        # ============== Download Videos with yt-dlp ============= #
        # ======================================================== #


        NewsFeed = feedparser.parse(Podcast_RSSURL)

        for rssItemCount in range(5):
            rssItem = NewsFeed.entries[rssItemCount]
            print ('------------------\n')
            print ('id: ' + rssItem.id)
            print ('title: ' + rssItem.title)
            RSSURL = rssItem.id
            IDString = os.path.basename(rssItem.id)
            print ('IDString: ' + IDString)

            bashcmd = "yt-dlp -v -o " + sMediaFolder + pChannelID + "/%(id)s.%(ext)s --write-info-json --no-write-playlist-metafiles --playlist-items 1,2,3,4,5 --restrict-filenames --download-archive " + pDownloadArchive + " --add-metadata --merge-output-format " + pFileFormat + " --format " + pFileQuality + " --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue --write-description " + RSSURL            # bashcmd = "yt-dlp -v -o '" + sMediaFolder + pChannelID + "/%(id)s.%(ext)s' --write-info-json --external-downloader aria2c --external-downloader-args '-c -j 10 -x 10 -s 10 -k 1M' --playlist-items 1,2,3,4,5,3,4,5 --restrict-filenames --download-archive '" + pDownloadArchive + "' --add-metadata --merge-output-format " + pFileFormat + " --format " + pFileQuality + " --abort-on-error --abort-on-unavailable-fragment --no-overwrites --continue --write-description " + pYouTubeURL
            # print(bashcmd)

            process = subprocess.Popen(bashcmd.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()

            print("output: " + str(output))
            print("error: " + str(error))

            print('Downloaded Video Files for ' + pName)
            print ('------------------      END YT-DLP\n')
    except Exception as err:
        print ('------------------      START YT-DLP ERROR\n')
        print (err)
        print (err.__annotations__)
        print (err.with_traceback)
        print ('\n------------------      END YT-DLP ERROR')

    if error == None:
        try:
            print("List Files")
            
            directory = os.fsencode(sMediaFolder + pChannelID)
                
            for file in os.listdir(directory):
                filename = os.fsdecode(file)
                filename_noext = ""
                filename_mediafile = ""
                filename_json = ""
                if filename.endswith(".description"): 
                    try:
                        pathname, extension = os.path.splitext(filename)
                        filename = pathname.split('/')
                        filename_noext = filename[-1]
                        
                        print("filename (no ext)" + filename_noext)
                    except:
                        print ('------------------      START GET EXT ERROR\n')
                        print (err)
                        print ('\n------------------      END GET EXT ERROR')

                    filename_json = sMediaFolder + pChannelID + "/" + filename_noext + ".info.json"
                    filename_mp3 = sMediaFolder + pChannelID + "/" + filename_noext + ".mp3"
                    filename_mp4 = sMediaFolder + pChannelID + "/" + filename_noext + ".mp4"

                    print("filename_json: " + filename_json)
                    print("filename_mp3: " + filename_mp3)
                    print("filename_mp4: " + filename_mp4)

                    filename_json_isfile = False
                    filename_mp3_isfile = False
                    filename_mp4_isfile = False

                    if os.path.isfile(filename_json):
                        print('The JSON file is present.')
                        filename_json_isfile = True
                    if os.path.isfile(filename_mp3):
                        print('The MP3 file is present.')
                        filename_mp3_isfile = True
                        filename_ext = filename_noext + ".mp3"
                    if os.path.isfile(filename_mp4):
                        print('The MP4 file is present.')
                        filename_mp4_isfile = True
                        filename_ext = filename_noext + ".mp4"

                    ytvideo_uid = ""
                    ytvideo_title = ""
                    ytvideo_thumbnail = ""
                    ytvideo_description = ""
                    ytvideo_uploader = ""
                    ytvideo_uploader_url = ""
                    ytvideo_channel_id = ""
                    ytvideo_channel_url = ""
                    ytvideo_duration = ""
                    ytvideo_webpage_url = ""
                    ytvideo_filesize = ""

                    if (filename_json_isfile == True and filename_mp4_isfile == True):
                        # print("ADD FILE TO RSS FEED: " + filename_mp4)
                        # print("Read JSON File")
                        f = open(filename_json)
                        data = json.load(f)
                        # print(data['id'])
                        
                        # Iterating through the json
                        # list
                        # for i in data['id']:
                        #     print(i)
                        
                        # ~~~~~~~~~~~~~ Get JSON Data ~~~~~~~~~~~~~ #
                        ytvideo_uid = data['id']
                        ytvideo_title = data['title']
                        ytvideo_description = data['description']
                        ytvideo_uploader = data['uploader']
                        ytvideo_uploader_id = data['uploader_id']
                        ytvideo_uploader_url = data['uploader_url']
                        ytvideo_channel_id = data['uploader_id']
                        ytvideo_channel_url = data['uploader_url']
                        ytvideo_duration = 0
                        ytvideo_webpage_url = data['webpage_url']
                        ytvideo_filesize = 0
                        ytvideo_thumbnail = data['thumbnail']
                        # ytvideo_thumbnail = "https://i.ytimg.com/vi_webp/" + ytvideo_uid + "/maxresdefault.webp"
                        # https://i.ytimg.com/vi_webp/wocnSQ4fsiI/maxresdefault.webp
                        # https://i.ytimg.com/vi/wocnSQ4fsiI/maxresdefault.jpg

                        print("ytvideo_uid: " + ytvideo_uid)
                        print("ytvideo_title: " + ytvideo_title)
                        print("ytvideo_uploader: " + ytvideo_uploader)
                        print("ytvideo_uploader_id: " + ytvideo_uploader_id)
                        print("ytvideo_uploader_url: " + ytvideo_uploader_url)
                        print("ytvideo_channel_id: " + ytvideo_channel_id)
                        print("ytvideo_channel_url: " + ytvideo_channel_url)
                        print("ytvideo_webpage_url: " + ytvideo_webpage_url)

                        # print('ytvideo_duration: ' + str(ytvideo_duration))
                        print ('\n------------------      Item (' + ytvideo_uid + ')')

                        # Closing file
                        f.close()

                        # # ======================================================== #
                        # # ================ Get Channel Information =============== #
                        # # ======================================================== #
                        ytvideo_channel_image = pChannelThumbnail
                        ytvideo_channel_desc = '{pName} (@{ytvideo_uploader}) - TikTok'


                        rssPathFile = rssPath + pChannelID + 'RSS.xml'
                        print("RSS File Path: " + rssPathFile)
                        if os.path.isfile(rssPathFile):
                            print('The RSS file is present. File: ' + rssPathFile)
                            rssPathFile_isfile = True

                            with open(rssPathFile, 'r') as rsstemplate:
                                RSSData = rsstemplate.readlines()
                                strRSSData = ''.join(RSSData)

                            # ======================================================== #
                            # =============== Add Items to Existing XML ============== #
                            # ======================================================== #

                            if ytvideo_uid in strRSSData:
                                print("Item (" + ytvideo_uid + ") already in RSS file")
                            else:
                                print("Item (" + ytvideo_uid + ") not in RSS file")
                                pubDate = time.strftime('%d/%m/%Y %H:%M:%S' + ' +1000')
                                # print("pubDate: " + pubDate)
                                RSSItemsData = '\t\t<item>\n\t\t\t<title><![CDATA[' + ytvideo_title + ']]></title>\n\t\t\t<description><![CDATA[' + ytvideo_description + ']]></description>\n\t\t\t<link>' + ytvideo_webpage_url + '</link>\n\t\t\t<guid isPermaLink="false">' + ytvideo_webpage_url + '</guid>\n\t\t\t<pubDate>' + str(pubDate) + '</pubDate>\n\t\t\t<podcast:chapters url="[ITEM_CHAPTER_URL]" type="application/json"/>\n\t\t\t<itunes:subtitle><![CDATA[' + ytvideo_uploader + ']]></itunes:subtitle>\n\t\t\t<itunes:summary><![CDATA[' + ytvideo_uploader + ']]></itunes:summary>\n\t\t\t<itunes:author><![CDATA[' + ytvideo_uploader + ']]></itunes:author>\n\t\t\t<author><![CDATA[' + ytvideo_uploader + ']]></author>\n\t\t\t<itunes:image href="' + ytvideo_thumbnail + '"/>\n\t\t\t<itunes:explicit>No</itunes:explicit>\n\t\t\t<itunes:keywords>youtube</itunes:keywords>\n\t\t\t<enclosure url="' + httpHost + '/podcasts/' + pChannelID + '/' + filename_ext + '" type="video/mpeg" length="' + str(ytvideo_filesize) + '"/>\n\t\t\t<podcast:person href="' + ytvideo_channel_url + '" img="' + ytvideo_thumbnail + '">' + ytvideo_uploader + '</podcast:person>\n\t\t\t<podcast:images srcset="' + ytvideo_thumbnail + ' 2000w"/>\n\t\t\t<itunes:duration>' + str(ytvideo_duration) + '</itunes:duration>\n\t\t</item>\n<!-- INSERT_ITEMS_HERE -->'
                                strRSSData = strRSSData.replace("<!-- INSERT_ITEMS_HERE -->",RSSItemsData)
                                rss = open(rssPath + pChannelID + "RSS.xml", "w")
                                rss.write(strRSSData)
                                rss.close()
                                print("Item added to RSS file: " + ytvideo_uid)

                                # ======================================================== #
                                # ==================== Notify Pushover =================== #
                                # ======================================================== #

                                NotifyPushover("apb75jkyb1iegxzp4styr5tgidq3fg","RSS Podcast Downloaded (" + pName + ")","<html><body>" + ytvideo_title + "<br /><br />--------------------------------------------<br /><br />" + ytvideo_description + "</body></html>",ytvideo_thumbnail)
                        else:
                            print('The RSS file is not present. File: ' + rssPathFile)
                            rssPathFile_isfile = False

                            # ======================================================== #
                            # ================== Create New RSS File ================= #
                            # ======================================================== #

                            with open(rssTemplatePath, 'r') as rsstemplate:
                                RSSData = rsstemplate.readlines()
                                strRSSData = ''.join(RSSData)
                            strRSSData = strRSSData.replace("[CHANNEL_LINK]",ytvideo_channel_url)
                            strRSSData = strRSSData.replace("[PODCAST_TITLE]",pName)
                            strRSSData = strRSSData.replace("[PODCAST_IMAGE]",ytvideo_channel_image)
                            strRSSData = strRSSData.replace("[PODCAST_DESCRIPTION]",ytvideo_channel_desc)

                            # ======================================================== #
                            # ================= Add Items to New XML ================= #
                            # ======================================================== #

                            pubDate = time.strftime('%d/%m/%Y %H:%M:%S' + ' +1000')
                            # print("pubDate: " + pubDate)
                            RSSItemsData = '\t\t<item>\n\t\t\t<title><![CDATA[' + ytvideo_title + ']]></title>\n\t\t\t<description><![CDATA[' + ytvideo_description + ']]></description>\n\t\t\t<link>' + ytvideo_webpage_url + '</link>\n\t\t\t<guid isPermaLink="false">' + ytvideo_webpage_url + '</guid>\n\t\t\t<pubDate>' + str(pubDate) + '</pubDate>\n\t\t\t<podcast:chapters url="[ITEM_CHAPTER_URL]" type="application/json"/>\n\t\t\t<itunes:subtitle><![CDATA[' + ytvideo_uploader + ']]></itunes:subtitle>\n\t\t\t<itunes:summary><![CDATA[' + ytvideo_uploader + ']]></itunes:summary>\n\t\t\t<itunes:author><![CDATA[' + ytvideo_uploader + ']]></itunes:author>\n\t\t\t<author><![CDATA[' + ytvideo_uploader + ']]></author>\n\t\t\t<itunes:image href="' + ytvideo_thumbnail + '"/>\n\t\t\t<itunes:explicit>No</itunes:explicit>\n\t\t\t<itunes:keywords>youtube</itunes:keywords>\n\t\t\t<enclosure url="' + httpHost + '/podcasts/' + pChannelID + '/' + filename_ext + '" type="video/mpeg" length="' + str(ytvideo_filesize) + '"/>\n\t\t\t<podcast:person href="' + ytvideo_channel_url + '" img="' + ytvideo_thumbnail + '">' + ytvideo_uploader + '</podcast:person>\n\t\t\t<podcast:images srcset="' + ytvideo_thumbnail + '2000w"/>\n\t\t\t<itunes:duration>' + str(ytvideo_duration) + '</itunes:duration>\n\t\t</item>\n<!-- INSERT_ITEMS_HERE -->'
                            strRSSData = strRSSData.replace("<!-- INSERT_ITEMS_HERE -->",RSSItemsData)
                            print("Item added to RSS file: " + ytvideo_uid)

                            # ======================================================== #
                            # ==================== Notify Pushover =================== #
                            # ======================================================== #

                            NotifyPushover("apb75jkyb1iegxzp4styr5tgidq3fg","RSS Podcast Downloaded (" + pName + ")","<html><body>" + ytvideo_title + "<br /><br />--------------------------------------------<br /><br />" + ytvideo_description + "</body></html>",ytvideo_thumbnail)

                            # ======================================================== #
                            # ==================== Write XML File ==================== #
                            # ======================================================== #

                            # print("----------------------")
                            # print(strRSSData)
                            # print("----------------------")

                            rss = open(rssPath + pChannelID + "RSS.xml", "w")
                            # rss = open("/mnt/pve/NFS_1TB/Python/" + pChannelID + "RSS.xml", "w")
                            rss.write(strRSSData)
                            rss.close()
                            print ('\n------------------      END Item (' + ytvideo_uid + ')')
                    continue
                else:
                    continue
        except Exception as err:
            print ('------------------      START GET FILES ERROR\n')
            print (err)
            print (err.__annotations__)
            print (err.with_traceback)
            print ('\n------------------      END GET FILES ERROR')


# ======================================================== #
# ===================== Script Start ===================== #
# ======================================================== #
settingsPath = '/config/settings.xml'
# settingsPath = '/mnt/pve/NFS_1TB/Python/settings.xml'
# rssTemplatePath = '/mnt/pve/NFS_1TB/Python/RSS_TEMPLATE_2.0.xml'
rssTemplatePath = '/config/RSS_TEMPLATE_2.0.xml'
rssPath = '/data/rss/'
# rssPath = '/mnt/pve/NFS_1TB/Python/'
httpHost = 'http://10.0.0.205:8383'
jsonFolder = '/config/json/'
jsonMediaFolder_YouTube = '/config/json/ytvideos/'
jsonMediaFolder_Twitch = '/config/json/twitchvideos/'
Twitch_DownloadArchive = "/mnt/pve/NFS_1TB/Python/youtube-dl-notifytwitch.txt"
# Twitch_DownloadArchive = "/config/json/youtube-dl-notifytwitch.txt"


Settings_Email = ''
Settings_MediaFolder = ''

IsValid_Email = False
IsValid_MediaFolder = False

print('=============================      PodcastsDownload\n')

if os.path.isfile(settingsPath):
    print('The settings file is present.')
    exist = True
else:
    print('The settings file is not present.')
    exist = False

# print(exist)

if exist == True:
    try:
        # parse an xml file by name
        file = minidom.parse(settingsPath)

        # ------ Get Email Tag ----- #
        xmlSettingsEmail = file.getElementsByTagName('Email')
        Settings_Email = xmlSettingsEmail[0].firstChild.data

        # ----- Validate Email ----- #

        # (EmailNotValidError, EmailSynaxError, EmailUndeliverableError)
        try:
            emailObject = validate_email(Settings_Email)
            # print("Valid Email: " + emailObject.email)
            IsValid_Email = True
            print('The email (' + Settings_Email + ') is valid.')
        except EmailNotValidError as EmailError:
            print('The email (' + Settings_Email + ') is valid.')
            IsValid_Email = False
            print ('------------------      START EMAIL ERROR\n')
            print (EmailError)
            print ('\n------------------      END EMAIL ERROR')

        # ---- Get MediaPath Tag --- #
        xmlSettingsMediaFolder = file.getElementsByTagName('MediaFolder')
        Settings_MediaFolder = xmlSettingsMediaFolder[0].firstChild.data
        
        # --- Validate MediaPath --- #
        if os.path.exists(Settings_MediaFolder):
            print('The folder (' + Settings_MediaFolder + ') is present.')
            IsValid_MediaFolder = True
        else:
            print('The folder (' + Settings_MediaFolder + ')  is not present.')
            IsValid_MediaFolder = False

        # ~~~~~~~~~ Print Valid Variables ~~~~~~~~~ #

        print("IsValid_Email: " + str(IsValid_Email))
        print("IsValid_MediaFolder: " + str(IsValid_MediaFolder))

        if IsValid_Email ==  True and IsValid_MediaFolder == True:
            print ('\n------------------      Valid Data\n')

            print("Email: " + Settings_Email)
            print("MediaFolder: " + Settings_MediaFolder)

            # ======================================================== #
            # ============= Loop through PodcastsDownload ============ #
            # ======================================================== #

            xmlPodcastsDownload = file.getElementsByTagName('PodcastDownload')
            for elem in xmlPodcastsDownload:
                Podcast_Name = elem.attributes['Name'].value
                Podcast_ChannelID = elem.attributes['ChannelID'].value
                Podcast_FileFormat = elem.attributes['FileFormat'].value
                Podcast_DownloadArchive = elem.attributes['DownloadArchive'].value
                Podcast_FileQuality = elem.attributes['FileQuality'].value
                Podcast_ChannelThumbnail = elem.attributes['ChannelThumbnail'].value
                Podcast_YouTubeURL = elem.attributes['YouTubeURL'].value
                
                print ('------------------      Podcast\n')
                print("Podcast_Name: " + Podcast_Name)
                print("Podcast_ChannelID: " + Podcast_ChannelID)
                print("Podcast_FileFormat: " + Podcast_FileFormat)
                print("Podcast_DownloadArchive: " + Podcast_DownloadArchive)
                print("Podcast_FileQuality: " + Podcast_FileQuality)
                print("Podcast_ChannelThumbnail: " + Podcast_ChannelThumbnail)
                print("Podcast_YouTubeURL: " + Podcast_YouTubeURL)
                print ('\n')

                # ======================================================== #
                # ====================== Run YT-DLP ====================== #
                # ======================================================== #

                Run_YTDLP(Settings_MediaFolder, Podcast_Name, Podcast_ChannelID, Podcast_FileFormat, Podcast_DownloadArchive, Podcast_FileQuality, Podcast_ChannelThumbnail, Podcast_YouTubeURL)
                DeleteOldFiles(7,Settings_MediaFolder + Podcast_ChannelID + "/")

            # ======================================================== #
            # ============== Loop through PodcastsNotify ============= #
            # ======================================================== #

            print('=============================      PodcastsNotifty\n')

            xmlPodcastsNotifty = file.getElementsByTagName('PodcastsNotifty')
            for elem in xmlPodcastsNotifty:
                Podcast_Name = elem.attributes['Name'].value
                Podcast_YouTubeURL = elem.attributes['YouTubeURL'].value
                
                print ('------------------      Podcast\n')
                print("Podcast_Name: " + Podcast_Name)
                print("Podcast_YouTubeURL: " + Podcast_YouTubeURL)

                NotifyYouTube(Podcast_Name, Podcast_YouTubeURL)

            # ======================================================== #
            # ======================= Read RSS ======================= #
            # ======================================================== #

            xmlPodcastsDownload = file.getElementsByTagName('RSSDownload')
            for elem in xmlPodcastsDownload:
                Podcast_Name = elem.attributes['Name'].value
                Podcast_ChannelID = elem.attributes['ChannelID'].value
                Podcast_FileFormat = elem.attributes['FileFormat'].value
                Podcast_DownloadArchive = elem.attributes['DownloadArchive'].value
                Podcast_FileQuality = elem.attributes['FileQuality'].value
                Podcast_ChannelThumbnail = elem.attributes['ChannelThumbnail'].value
                # Podcast_RSSURL = elem.attributes['RSSFeed'].value
                Podcast_TikTokFeed = elem.attributes['TikTokFeed'].value
                Podcast_TikTokUsername = elem.attributes['TikTokUsername'].value
                Podcast_RSSURL = str(Podcast_TikTokFeed) + str(Podcast_TikTokUsername)
                
                print ('------------------      Podcast\n')
                print("Podcast_Name: " + Podcast_Name)
                print("Podcast_ChannelID: " + Podcast_ChannelID)
                print("Podcast_FileFormat: " + Podcast_FileFormat)
                print("Podcast_DownloadArchive: " + Podcast_DownloadArchive)
                print("Podcast_FileQuality: " + Podcast_FileQuality)
                print("Podcast_ChannelThumbnail: " + Podcast_ChannelThumbnail)
                print("Podcast_TikTokUsername: " + Podcast_TikTokUsername)
                print("Podcast_RSSURL: " + str(Podcast_RSSURL))
                print ('\n')

                # ======================================================== #
                # ====================== Run YT-DLP ====================== #
                # ======================================================== #

                Run_RSS_YTDLP(Settings_MediaFolder, Podcast_Name, Podcast_ChannelID, Podcast_FileFormat, Podcast_DownloadArchive, Podcast_FileQuality, Podcast_ChannelThumbnail, Podcast_RSSURL)
                DeleteOldFiles(7,Settings_MediaFolder + Podcast_ChannelID + "/")

            # ======================================================== #
            # ============== Loop through TwitchNotifty ============= #
            # ======================================================== #

            # print('=============================      TwitchNotifty\n')

            # xmlPodcastsNotifty = file.getElementsByTagName('TwitchNotifty')
            # for elem in xmlPodcastsNotifty:
            #     Podcast_Name = elem.attributes['Name'].value
            #     Podcast_YouTubeURL = elem.attributes['YouTubeURL'].value
                
            #     print ('------------------      Podcast\n')
            #     print("Podcast_Name: " + Podcast_Name)
            #     print("Podcast_YouTubeURL: " + Podcast_YouTubeURL)

            #     NotifyTwitch(Podcast_Name, Podcast_YouTubeURL)

            # ======================================================== #
            # ======================================================== #
            # ======================================================== #
        else:
            print ('\n------------------')
            print("Settings Not Valid")
            print ('\n------------------')


        # ~~~~~~~~~~~~~ Validate Email ~~~~~~~~~~~~ #

    except ExpatError as XMLerr:
        print ('------------------      START XML ERROR\n')
        print (XMLerr)
        print ('\n------------------      END XML ERROR')
else:
    print('Settings Path Not Valid')