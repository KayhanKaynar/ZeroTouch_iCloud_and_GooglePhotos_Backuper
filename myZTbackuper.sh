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
folderlist >> $folderlistfile
cat $folderlistfile
readarray -t arr < $folderlistfile

# This arrays first line is being excluded ( It contains time , debug and authenticating,not folder names available on Icloud) :
arr=( "${arr[@]:1:3}" "${arr[@]:4}" )


# This is the list which folders are being excluded to download from ICloud account.
# Apple devices ( Icloud ) stores all the media data as categorized like panoramas,videos, slow motions.
# All Photos includes all the library. So if you want to exclude a folder from being download, you can add it under a line in remove array below : 
remove=(
Time-lapse
'Recently Deleted'
Slo-mo
Live
Bursts
Favorites
Panoramas
Hidden
Screenshots
)

# With a for loop remove arrays elemenst are being removed from folders array :
for target in "${remove[@]}"; do
  for i in "${!arr[@]}"; do
    if [[ ${arr[i]} = $target ]]; then
      unset 'arr[i]'
    fi
  done
done

# With the remove operation, the removed indices are getting null, because of that we are
# getting new indices starting from 0 until length as copying the arrayto new one:
arr=("${arr[@]}")

# Printing the array to see the result :
echo "Icloud downloads list :"
declare -p arr

# Processed array is being stored on a dummy file :
printf "%s\n" "${arr[@]}" > $editedfolderlistfile

# In here I check the folders list if it contaions any Turkish character,
# Because icloudpd library is giving errors if the folders are containing Turkish characters,
# So,If you are not a Turkish guy, you can exclude this part,
# Also, there is a sendpushnotification alias on found errors to inform the admin.
index=-1
for i in "${arr[@]}"; do
  index=$(( index + 1 ))
  echo "index:$index value: ${arr[index]}"
  for reqsubstr in 'İ' 'ı' 'Ü' 'ü' 'Ş' 'ş' 'Ç' 'ç' 'Ö' 'ö' 'Ğ' 'ğ';do
  if [ -z "${i##*$reqsubstr*}" ] ;then
      echo "String '$i' contains turkish char: '$reqsubstr' and unsetting this indice "
      sendpushnotification "iCloud albumlerde Turkce karakter bulundu: '$i' " &&  unset 'arr[index]' && break
  fi
  done
done

# After a few process, lets start to download all the icloud folders. 🍺 :)
for i in "${arr[@]}"; do
  echo "element is $i"
  [ ! -d "$MyMainDir/$i" ] && echo "creating folder $i" &&  mkdir "$MyMainDir/$i"
  icloudpd -u $user -p $pass --directory "$MyMainDir/$i" --folder-structure none -a "$i"
  wait
done


# After Icloud downloads finished to local directory, the next step is uploading the new folders and media to Google Photos.
# For this time again, we can exclude some folders if we do not want to upload them to Google Photos like
# All Photos or Videos folders.
# I just want to add folders that is just meaningfull for me with my naming standarts like Year Month - Smt About Folder
removal=(
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
)

# A new remove process for the Google Upload process folders exclusion :
for target in "${removal[@]}"; do
  for i in "${!arr[@]}"; do
    if [[ ${arr[i]} = $target ]]; then
      unset 'arr[i]'
    fi
  done
done

# Copy the array to new indices :
arr=("${arr[@]}")

# Printing array if there is a problem for troubleshoot on logs :
echo "Google Photos upload list :"
declare -p arr

# Google Photos upload with rclone with automated interactive shell prompt executions :
for i in "${arr[@]}"; do
  echo "For Google Uploads element is $i"
  printf '!\n' | rclone sync -i "$MyMainDir/$i" "YourRemoteName:album/$i"
  wait
done

rm $editedfolderlistfile
rm $folderlistfile

exit 0
