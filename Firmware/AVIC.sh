#! /bin/bash 
# AVIC.sh - Unpacks SYSTEM.img from the AVIC firmware for modification, waits for an input, then repackages.

# THIS FILE AND DERRIVITIVE WORKS ARE SUBJECT TO ALL TERMS OF LICENSING BELOW!
# License: 
# Term 0: If you modify this file, you must share any changes with the file creators and/or publicly on AVIC411.com
# Term 1: If you find a new use, share changes on AVIC411.com
# Term 2: If it worked say thanks.
# Term 3: IF anyone claims this is black magic, I'm going to flip.

# By bass_rock http://avic411.com/index.php?/user/116652-bass-rock/
# Heavily modified by AdamOutler adamoutler@gmail.com
# http://avic411.com/index.php?/topic/80945-upgrading-nex4000-to-nex4100-work-in-progress/page-19#entry332704
# Heavily modified by bass_rock yet again @bass_rock


#this function is called when system is not Linux, user is not root, or user did not specify a file
function usage() {
  echo "usage:"
  echo "  AVIC.sh /path_to/firmware.zip [AVIC Model] [AVIC firmware version]"
  echo "where AVIC Model = 5000, or 8100"
  echo "where AVIC firmware version = 140 or 150" 
  echo "make sure that mkboot is in a folder mkbootimg_tools next to this script"
  exit
}


function generateVERFile() {
	originalVerFile=$1
	prgFile=$2

	dd if="$originalVerFile" of="$originalVerFile.part1" bs=176 skip=0 count=1
	
	SIZE="$(stat -c%s $prgFile)"
	echo "$prgFile size is: $SIZE"
	UNSWAPPEDHEXSIZE="$(printf '%x\n' $SIZE)"
	vSIZE="$UNSWAPPEDHEXSIZE"
	SWAPPEDHEXSIZE="${vSIZE:6:2}${vSIZE:4:2}${vSIZE:2:2}${vSIZE:0:2}"
	LEN=$(echo ${#SWAPPEDHEXSIZE})
	if [ $LEN -eq 6 ]; then
        SWAPPEDHEXSIZE=${SWAPPEDHEXSIZE}00
	fi
	UNSWAPPEDHEXCRC="$(crc32 $prgFile)"
	vCRC="$UNSWAPPEDHEXCRC"
	SWAPPEDHEXCRC="${vCRC:6:2}${vCRC:4:2}${vCRC:2:2}${vCRC:0:2}"

	echo "$prgFile Unswapped prg size hex is: $UNSWAPPEDHEXSIZE"
	echo "$prgFile Swapped prg size hex is: $SWAPPEDHEXSIZE"
	echo "$prgFile Unswapped prg crc hex is: $UNSWAPPEDHEXCRC"
	echo "$prgFile Swapped prg crc hex is: $SWAPPEDHEXCRC"
	
	#perl -e "print pack 'H*', '${defaultheaderver}${SWAPPEDHEXSIZE}${SWAPPEDHEXCRC}A55A5AA5'" > PJ${version}PLT.VERSTART

	
	perl -e "print pack 'H*', '${SWAPPEDHEXSIZE}${SWAPPEDHEXCRC}A55A5AA5'" > "$originalVerFile.part2"

	cat "$originalVerFile.part1" "$originalVerFile.part2" > "$originalVerFile.combined"

	rm -rf "$originalVerFile.part1"
	rm -rf "$originalVerFile.part2"

	UNSWAPPEDHEXCRC="$(crc32 $originalVerFile.combined)"
	vCRC="$UNSWAPPEDHEXCRC"
	SWAPPEDHEXCRC="${vCRC:6:2}${vCRC:4:2}${vCRC:2:2}${vCRC:0:2}"
	echo "$originalVerFile.combined Unswapped verstart crc hex is: $UNSWAPPEDHEXCRC"
	echo "$originalVerFile.combined Swapped verstart crc hex is: $SWAPPEDHEXCRC"

	perl -e "print pack 'H*', '${SWAPPEDHEXCRC}'" > "$originalVerFile.combined1"
	
	cat "$originalVerFile.combined" "$originalVerFile.combined1" > "$originalVerFile.new"
	
	rm -rf "$originalVerFile.combined"
	rm -rf "$originalVerFile.combined1"
	
	rm -rf "$originalVerFile"
	
	mv "$originalVerFile.new" "$originalVerFile"
}

function generatePRGFile() {
	originalPRGFile=$1
	imgToMakePRG=$2

	dd if=$originalPRGFile of=originalPRGFile.header bs=4 skip=3 count=125
	#get image size
	# for mac
	# SIZE="$(stat -f%z PJ${version}PLT.IMG)"
	#for linux
	SIZE="$(stat -c%s ${imgToMakePRG})"
	echo "${imgToMakePRG} size is: $SIZE"
	
	#We have to swap the hex values from big endian to little endian cause the NEX is arm.
	UNSWAPPEDHEXSIZE="$(printf '%x\n' $SIZE)"
	vSIZE="$UNSWAPPEDHEXSIZE"
	SWAPPEDHEXSIZE="${vSIZE:6:2}${vSIZE:4:2}${vSIZE:2:2}${vSIZE:0:2}"	
	LEN=$(echo ${#SWAPPEDHEXSIZE})
	if [ $LEN -eq 6 ]; then
        SWAPPEDHEXSIZE=${SWAPPEDHEXSIZE}00
	fi
	UNSWAPPEDHEXCRC="$(crc32 ${imgToMakePRG})"
	vCRC="$UNSWAPPEDHEXCRC"
	SWAPPEDHEXCRC="${vCRC:6:2}${vCRC:4:2}${vCRC:2:2}${vCRC:0:2}"

	echo "${imgToMakePRG} Unswapped size hex is: $UNSWAPPEDHEXSIZE"
	echo "${imgToMakePRG} Swapped size hex is: $SWAPPEDHEXSIZE"
	echo "${imgToMakePRG} Unswapped crc hex is: $UNSWAPPEDHEXCRC"
	echo "${imgToMakePRG} Swapped crc hex is: $SWAPPEDHEXCRC"
	
	#create new header
	perl -e "print pack 'H*', 'A55A5AA5${SWAPPEDHEXSIZE}${SWAPPEDHEXCRC}'" > firstheaderhalf.header
	cat firstheaderhalf.header originalPRGFile.header "$imgToMakePRG" > "$originalPRGFile.new"
	rm -rf firstheaderhalf.header
	rm -rf originalPRGFile.header
	
	rm -rf "$originalPRGFile"
	rm -rf "$imgToMakePRG"
	mv "$originalPRGFile.new" "$originalPRGFile"
}

function createImgFile() {
	prgFile=$1
	newImgFile=$2		
	dd if="$prgFile" of="$newImgFile" bs=512 skip=1
}


function openupBOOTStyleImage() {
	directory=$1
	imageToOpen=$2
	workdir=$3

	cd "$directory"
	
	abootimg -x "$imageToOpen"
	
	"$workdir/../mkbootimg_tools/mkboot" "$imageToOpen" ./newUnpack
	
	cd "$workDir"
}

function closeupBOOTStyleImage() {
	directory=$1
	imageToSave=$2
	workdir=$3

	cd "$directory"
		
	"$workdir/../mkbootimg_tools/mkboot" ./newUnpack "$imageToSave.NEW"
	
	rm -rf "$imageToSave" 
	
	mv "$imageToSave.NEW" "$imageToSave"
	
 	rm -rf bootimg.cfg
 	rm -rf initrd.img
 	rm -rf zImage
 	rm -rf newUnpack
	
	cd "$workdir"
}

#exit on any error
set -e

#verify system is Linux and user is root and specifed a file
test "$(uname)" = "Linux" || $(echo "this only works on linux" && usage)
test $(id -u) -eq "0" || $(echo "you must run as root" && usage)
test -z "$1" && $(echo "you must specify a file" && usage)

#set variables for use (default AVIC-5000NEX, Version 140)
AVICZIP="$1" 
m=$2
model=${m:="5000"}
v=$3 
version=${v:="140"}

#SETUP
workdir=$(pwd)"/work"
mkdir -p $workdir/
unzip -o "$AVICZIP" -d $workdir/
cd "$imageDir"


#PLATFORM Files
SYSTEMmount="$workdir/AVIC${model}NEX/PLATFORM/SYSTEM"
PLTimgFile="$workdir/AVIC${model}NEX/PLATFORM/PJ${version}PLT.IMG"
PLTprgFile="$workdir/AVIC${model}NEX/PLATFORM/PJ${version}PLT.PRG"
PLTverFile="$workdir/AVIC${model}NEX/PJ${version}PLT.VER"
PLTdirectory="$workdir/AVIC${model}NEX/PLATFORM"

#USERDATA Files
SYSTEMUSERDATAmount="$workdir/AVIC${model}NEX/USERDATA/SYSTEM"
DATimgFile="$workdir/AVIC${model}NEX/USERDATA/PJ${version}DAT.IMG"
DATprgFile="$workdir/AVIC${model}NEX/USERDATA/PJ${version}DAT.PRG"
DATverFile="$workdir/AVIC${model}NEX/PJ${version}DAT.VER"
DATdirectory="$workdir/AVIC${model}NEX/USERDATA"

#SNAPSHOT Files
SYSTEMSNAPSHOTmount="$workdir/AVIC${model}NEX/SNAPSHOT/SYSTEM"
SNAPSHOTimgFile="$workdir/AVIC${model}NEX/SNAPSHOT/SNAPSHOT.IMG"
SNAPSHOTprgFile="$workdir/AVIC${model}NEX/SNAPSHOT/SNAPSHOT.PRG"
SNAPSHOTverFile="$workdir/AVIC${model}NEX/SNAPSHOT.PRG.VER"
SNAPSHOTdirectory="$workdir/AVIC${model}NEX/SNAPSHOT"

#HIBENDIR Files
SYSTEMHIBENDIRmount="$workdir/AVIC${model}NEX/HIBENDIR/SYSTEM"
HIBENDIRimgFile="$workdir/AVIC${model}NEX/HIBENDIR/HIBENDIR.IMG"
HIBENDIRprgFile="$workdir/AVIC${model}NEX/HIBENDIR/HIBENDIR.PRG"
HIBENDIRverFile="$workdir/AVIC${model}NEX/HIBENDIR.PRG.VER"
HIBENDIRdirectory="$workdir/AVIC${model}NEX/HIBENDIR"

#BOOT Files
BOTimgFile="$workdir/AVIC${model}NEX/BOOT/PJ${version}BOT.IMG"
BOTprgFile="$workdir/AVIC${model}NEX/BOOT/PJ${version}BOT.PRG"
BOTverFile="$workdir/AVIC${model}NEX/PJ${version}BOT.VER"
BOTdirectory="$workdir/AVIC${model}NEX/BOOT"

#RECOVERY Files
RECimgFile="$workdir/AVIC${model}NEX/RECOVERY/PJ${version}REC.IMG"
RECprgFile="$workdir/AVIC${model}NEX/RECOVERY/PJ${version}REC.PRG"
RECverFile="$workdir/AVIC${model}NEX/PJ${version}REC.VER"
RECdirectory="$workdir/AVIC${model}NEX/RECOVERY"

#EASYRECOVERY Files
ERYimgFile="$workdir/AVIC${model}NEX/RECOVERYEASY/PJ${version}ERY.IMG"
ERYprgFile="$workdir/AVIC${model}NEX/RECOVERYEASY/PJ${version}ERY.PRG"
ERYverFile="$workdir/AVIC${model}NEX/PJ${version}ERY.VER"
ERYdirectory="$workdir/AVIC${model}NEX/RECOVERYEASY"

#READY THE PLATFORM

#create img file of the system image.
createImgFile "$PLTprgFile" "$PLTimgFile"

#ignore errors while we create a new folder for working with image
set +e
umount "$SYSTEMmount" 2>&1
test -e "$SYSTEMmount" && rm -rf "$SYSTEMmount"
mkdir $SYSTEMmount
set -e

#mount the image
mount "$PLTimgFile" "$SYSTEMmount"


#READY THE USERDATA

#create img file of the system image.
createImgFile "$DATprgFile" "$DATimgFile"

#ignore errors while we create a new folder for working with image
set +e
umount "$SYSTEMUSERDATAmount" 2>&1
test -e "$SYSTEMUSERDATAmount" && rm -rf "$SYSTEMUSERDATAmount"
mkdir $SYSTEMUSERDATAmount
set -e

#mount the image
mount "$DATimgFile" "$SYSTEMUSERDATAmount"

#READY THE SNAPSHOT

#create img file of the system image.
createImgFile "$SNAPSHOTprgFile" "$SNAPSHOTimgFile"

# #ignore errors while we create a new folder for working with image
# set +e
# umount "$SYSTEMSNAPSHOTmount" 2>&1
# test -e "$SYSTEMSNAPSHOTmount" && rm -rf "$SYSTEMSNAPSHOTmount"
# mkdir $SYSTEMSNAPSHOTmount
# set -e
# 
# #mount the image
# mount "$SNAPSHOTimgFile" "$SYSTEMSNAPSHOTmount" || echo "failed"
# 
# 
# #READY THE HIBENDIR
# 
# #create img file of the system image.
# createImgFile "$HIBENDIRprgFile" "$HIBENDIRimgFile"
# 
# #ignore errors while we create a new folder for working with image
# set +e
# umount "$SYSTEMHIBENDIRmount" 2>&1
# test -e "$SYSTEMHIBENDIRmount" && rm -rf "$SYSTEMHIBENDIRmount"
# mkdir $SYSTEMHIBENDIRmount
# set -e
# 
# #mount the image
# mount "$HIBENDIRimgFile" "$SYSTEMHIBENDIRmount" || echo "failed"

#READY THE BOOT
createImgFile "$BOTprgFile" "$BOTimgFile"

openupBOOTStyleImage "$BOTdirectory" "$BOTimgFile" "$workdir"	

#READY THE RECOVERY
createImgFile "$RECprgFile" "$RECimgFile"

openupBOOTStyleImage "$RECdirectory" "$RECimgFile" "$workdir"	

#READY THE EASYRECOVERY
createImgFile "$ERYprgFile" "$ERYimgFile"

openupBOOTStyleImage "$ERYdirectory" "$ERYimgFile" "$workdir"	

#WAIT FOR USER TO FINISH


echo "You can now modify all the open folders"
read -n 1 -p "Press any key to continue" isdone

sync #ensure all changes are written to disk


#TIME TO CLOSE UP


#CLOSE UP PLATFORM

umount "$SYSTEMmount"
test -e "$SYSTEMmount" && rm -rf "$SYSTEMmount"

generatePRGFile "$PLTprgFile" "$PLTimgFile"
generateVERFile "$PLTverFile" "$PLTprgFile"

#CLOSE UP USERDATA

umount "$SYSTEMUSERDATAmount"
test -e "$SYSTEMUSERDATAmount" && rm -rf "$SYSTEMUSERDATAmount"

generatePRGFile "$DATprgFile" "$DATimgFile"
generateVERFile "$DATverFile" "$DATprgFile"

# #CLOSE UP SNAPSHOT
# 
# umount "$SYSTEMSNAPSHOTmount"
# test -e "$SYSTEMSNAPSHOTmount" && rm -rf "$SYSTEMSNAPSHOTmount"
# 
# generatePRGFile "$SNAPSHOTprgFile" "$SNAPSHOTimgFile"
# generateVERFile "$SNAPSHOTverFile" "$SNAPSHOTprgFile"

#CLOSE UP BOOT
 
closeupBOOTStyleImage "$BOTdirectory" "$BOTimgFile" "$workdir"

generatePRGFile "$BOTprgFile" "$BOTimgFile"
generateVERFile "$BOTverFile" "$BOTprgFile"

#CLOSE UP RECOVERY
 
closeupBOOTStyleImage "$RECdirectory" "$RECimgFile" "$workdir"

generatePRGFile "$RECprgFile" "$RECimgFile"
generateVERFile "$RECverFile" "$RECprgFile"


#CLOSE UP EASY RECOVERY
 
closeupBOOTStyleImage "$ERYdirectory" "$ERYimgFile" "$workdir"

generatePRGFile "$ERYprgFile" "$ERYimgFile"
generateVERFile "$ERYverFile" "$ERYprgFile"

echo "WOOO! Your custom ROM is backed and ready!"