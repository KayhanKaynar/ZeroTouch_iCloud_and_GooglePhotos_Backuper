# ZeroTouch_iCloud_and_GooglePhotos_Backuper

# This project is written to download iCloud Photos to local folder on your server and upload all the media to your Google Photos account.
# For the project iCloudpd and rclone is being used to process the data. You can find them on :
# iCloudpd : https://github.com/icloud-photos-downloader/icloud_photos_downloader
# rclone   : https://rclone.org/googlephotos/
#
#
# Kayhan Kaynar , August, 2022
# Icloud Downloader V1.0
# kayhan.kaynar@hotmail.com

Some example logs:
02.09.2022 00:08

There are 3 folders to download from your iCloud and these photo folders are:
declare -a folders=([0]="Videos" [1]="All Photos" [2]="Test")

Checking for the folders if they have Turkish characters :
index:0 value: Videos
index:1 value: All Photos
index:2 value: Test

iCloud download folder is Videos
2022-09-02 00:08:45 DEBUG    Authenticating...
2022-09-02 00:08:50 DEBUG    Looking up all photos and videos from album Videos...
2022-09-02 00:08:50 INFO     Downloading 145 original photos and videos to /mnt/ExtHDD/Fotograflarim/Videos ...
/mnt/ExtHDD/Fotograflarim/Videos/IMG_5470.MOV already exists.: 100%|####################################################################################################################################| 145/145 [00:07<00:00, 19.16it/s]
2022-09-02 00:08:58 INFO     All photos have been downloaded!

iCloud download folder is All Photos
2022-09-02 00:08:59 DEBUG    Authenticating...
2022-09-02 00:09:04 DEBUG    Looking up all photos and videos from album All Photos...
2022-09-02 00:09:04 INFO     Downloading 955 original photos and videos to /mnt/ExtHDD/Fotograflarim/All Photos ...
/mnt/ExtHDD/Fotograflarim/All Photos/IMG_5448.JPG already exists.: 100%|################################################################################################################################| 955/955 [00:54<00:00, 17.41it/s]
2022-09-02 00:09:59 INFO     All photos have been downloaded!

iCloud download folder is Test
2022-09-02 00:10:00 DEBUG    Authenticating...
2022-09-02 00:10:06 DEBUG    Looking up all photos and videos from album Test...
2022-09-02 00:10:06 INFO     Downloading 4 original photos and videos to /mnt/ExtHDD/Fotograflarim/Test ...
Downloading /mnt/ExtHDD/Fotograflarim/Test/IMG_6794.JPG: 100%|##############################################################################################################################################| 4/4 [00:06<00:00,  1.62s/it]
2022-09-02 00:10:13 INFO     All photos have been downloaded!

There are 1 folders to upload to Google Photos and these folders are:
declare -a folders=([0]="Test")

Upload in progress to Google Photos for folder : Test
rclone: copy "IMG_6794.JPG"?
y) Yes, this is OK (default)
n) No, skip this
s) Skip all copy operations with no more questions
!) Do all copy operations with no more questions
q) Exit rclone now.
y/n/s/!/q> 2022/09/02 00:10:14 NOTICE: Doing all copy operations from now on without asking
2022/09/02 00:10:35 NOTICE: 
Transferred:       10.359 MiB / 10.359 MiB, 100%, 480.093 KiB/s, ETA 0s
Transferred:            4 / 4, 100%
Elapsed time:        22.1s


Sending logs via e-mail...
Sent...

Finished.
02.09.2022 00:10
