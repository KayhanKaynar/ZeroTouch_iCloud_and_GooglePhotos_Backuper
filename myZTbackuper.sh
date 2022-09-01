#!/bin/bash
#
# This project is written to download iCloud Photos to local folder on your server and upload all the media to your Google Photos account.
# For the project iCloudpd and rclone is being used to process the data. You can find them on :
# iCloudpd : https://github.com/icloud-photos-downloader/icloud_photos_downloader
# rclone   : https://rclone.org/googlephotos/
#
#
# Kayhan Kaynar , August, 2022
# Icloud Downloader V1.0
# kayhan.kaynar@hotmail.com

user="XXXXX@hotmail.com"
pass="XXXXXXX"
MyMainDir=/mnt/ExtHDD/Fotograflarim
folderlistfile=$(tempfile)
editedfolderlistfile=$(tempfile)
PATH=$PATH:"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# If it does not exist, main download directory is being created.
# [ ! -d "$MyMainDir" ] && mkdir $MyMainDir

showwatch(){
echo "$(date +%d).$(date +%m).$(date +%Y) $(date +%H):$(date +%M)"
}

showwatch

# First, all the folders are being listed on ICloud account.
folderlist(){
icloudpd -u $user -p $pass -l
}

# All the output in icloudpd output, is stored on a dummy text file to analyse the folders list,
# and we read the dummy text file to exclude the first line of the output, which is not necessary for us,this is smt like below :
# 2022-08-14 08:00:02 DEBUG    Authenticating...
# Time-lapse
# Recently Deleted
# Videos
# Slo-mo
# 2022 August - Joy With Friends
# 2022 May - My Birthday Party
# All Photos
# Live
# Bursts
# Favorites
# Panoramas
# Hidden
# Screenshots

#folderlist >> $folderlistfile
#echo -e "\r"
#cat $folderlistfile
#readarray -t folders < $folderlistfile

IFS=$'\n' folders=($(folderlist))

# This arrays first line is being excluded ( It contains time , debug and authenticating,not folder names available on Icloud) :
# Setting the new folders array to start from indis 1 to all instead of indice 0 to remove the first line:
folders=("${folders[@]:1}")


# This is the list which folders are being excluded to download from ICloud account.
# Apple devices ( Icloud ) stores all the media data as categorized like panoramas,videos, slow motions.
# All Photos includes all the library. So if you want to exclude a folder from being download, you can add it under a line in remove array below : 
excludedfolders=(
Time-lapse
'Recently Deleted'
Slo-mo
Live
Bursts
Favorites
Panoramas
Hidden
Screenshots
Twitter
CapCut
Instagram
)

# With a for loop remove arrays elemenst are being removed from folders array :
for target in "${excludedfolders[@]}"; do
  for i in "${!folders[@]}"; do
    if [[ ${folders[i]} = $target ]]; then
      unset 'folders[i]'
    fi
  done
done

# With the remove operation, the removed indices are getting null, because of that we are
# getting new indices starting from 0 until length as copying the arrayto new one:
folders=("${folders[@]}")

# Printing the array to see the result :
echo -e "\r"
echo "There are ${#folders[@]} folders to download from your iCloud and these photo folders are:"
declare -p folders

# Processed array is being stored on a dummy file :
#printf "%s\n" "${folders[@]}" > $editedfolderlistfile

# In here I check the folders list if it contaions any Turkish character,
# Because icloudpd library is giving errors if the folders are containing Turkish characters,
# So,If you are not a Turkish guy, you can exclude this part,
# Also, there is a sendpushnotification alias on found errors to inform the admin.

echo -e "\r"
echo "Checking for the folders if they have Turkish characters :"
index=-1
for i in "${folders[@]}"; do
  index=$(( index + 1 ))
  echo "index:$index value: ${folders[index]}"
  for reqsubstr in 'İ' 'ı' 'Ü' 'ü' 'Ş' 'ş' 'Ç' 'ç' 'Ö' 'ö' 'Ğ' 'ğ';do
  if [ -z "${i##*$reqsubstr*}" ] ;then
      echo "String '$i' contains turkish char: '$reqsubstr' and unsetting this indice "
      sendpushnotification "iCloud albumlerde Turkce karakter bulundu: '$i' " &&  unset 'folders[index]' && break
  fi
  done
done

# After a few process, lets start to download all the icloud folders. 🍺 :)
for i in "${folders[@]}"; do
  echo -e "\r"
  echo "iCloud download folder is $i"
  [ ! -d "$MyMainDir/$i" ] && echo "creating folder $i" &&  mkdir "$MyMainDir/$i"
  icloudpd -u $user -p $pass --directory "$MyMainDir/$i" --folder-structure none -a "$i"
  wait
done

# After Icloud downloads finished to local directory, the next step is uploading the new folders and media to Google Photos.
# For this time again, we can exclude some folders if we do not want to upload them to Google Photos like
# All Photos or Videos folders.
# I just want to add folders that is just meaningfull for me with my naming standarts like Year Month - Smt About Folder

GPexcludelist=(
'All Photos'
Time-lapse
Videos
'Recently Deleted'
Slo-mo
Live
Bursts
Favorites
Panoramas
Hidden
Screenshots
WhatsApp
)

# A new remove process for the Google Upload process folders exclusion :
for target in "${GPexcludelist[@]}"; do
  for i in "${!folders[@]}"; do
    if [[ ${folders[i]} = $target ]]; then
      unset 'folders[i]'
    fi
  done
done

# Copy the array to new indices :
folders=("${folders[@]}")

# Printing array if there is a problem for troubleshoot on logs :
echo -e "\r"
echo "There are ${#folders[@]} folders to upload to Google Photos and these folders are:"
declare -p folders

# Google Photos upload with rclone with automated interactive shell prompt executions :
for i in "${folders[@]}"; do
  echo -e "\r"
  echo "Upload in progress to Google Photos for folder : $i"
  printf '!\n' | rclone sync -i "$MyMainDir/$i" "Kayhan2GP:album/$i"
  wait
done

echo -e "\r"
echo "Sending logs via e-mail..."
cat /var/log/My_Rotating_Logs/MyICloudDownloader.log |  msmtp kayhan.kaynar@hotmail.com
echo "Sent..."

echo -e "\r"
#echo "Removing unwanted files..."
#rm $editedfolderlistfile
#rm $folderlistfile
echo "Finished."

showwatch

exit 0
