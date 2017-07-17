#!/bin/bash
#
# before you do anything, please read through this file carefully
#
# USAGE: 
# 
# sudo sh nas_setup.sh [--install|--remove]
#
# Options:
# 
# --install: Installs NAS requirements and Setup NAS on boot with config given below
#
# --remove: uninstalls NAS requirements and removes NAS on boot
#

###############################################################################
###############################################################################
#                              CONFIGURATION                                  #
###############################################################################
###############################################################################

# UUID of HDD for NAS
# use command: ls -l /dev/disk/by-uuid
HDD_UUID="927A87117A86F0F1"

# partition where HDD will be mounted
MOUNT_AT="/media/USBHDD"

# name of folder as it appears in network share
NAS_NAME="NASpi"

# new NAS user
NAS_USER="nasusr"

# NAS users password
NAS_USER_PASS="mynaspass@123"

# NAS samba config additions
NAS_SAMBA_CONFIG="

[$NAS_NAME]
comment = NAS Folder
path = $MOUNT_AT
valid users = $NAS_USER
force group = users
create mask = 0660
directory mask = 0771
read only = no
writable = yes"

# lines to be added to fstab
# fstab configuration
fstab_config="
# added for $NAS_NAME
UUID=$HDD_UUID $MOUNT_AT auto noatime 0 0"


###############################################################################
###############################################################################
#                              FUNCTIONS                                      #
###############################################################################
###############################################################################

clean_fstab() {

	printf "\n\n++++++++++++++++++ cleaning fstab ++++++++++++++++++++"
	sudo cp -f /etc/fstab.clean_old  /etc/fstab

}

add_HDD_to_fstab_by_uuid() {

	printf "\n\n++++++++++++++++++ setup fstab for AutoMount ++++++++++++++++++++"

    # check if current fstab was previously changed
    if grep -Fxq "$NAS_NAME" /etc/fstab; then

    	echo "current fstab was modified for NAS."
    	echo "replace current fstab with a clean old one."
    	sudo cp -f /etc/fstab.clean_old  /etc/fstab

    	echo "adding HDD to fstab..."
    	echo "$fstab_config" | sudo tee --append /etc/fstab

    else

    	echo "current fstab is clean."
    	echo "making backup of clean fstab."
    	sudo cp -f /etc/fstab /etc/fstab.clean_old

    	echo "adding HDD to fstab..."
    	echo "$fstab_config" | sudo tee --append /etc/fstab

    fi
}



install_ntfs_drivers() {
	printf "\n\n++++++++++++++++++ installing ntfs drives ++++++++++++++++++++"

	sleep 0.5
	sudo apt install ntfs-3g -y
}


remove_ntfs_drivers() {
	printf "\n\n++++++++++++++++++ removing ntfs drives ++++++++++++++++++++"

	sleep 0.5
	sudo apt remove ntfs-3g -y
}


unmount_drive_by_uuid() {
	# unmount $1

	printf "\n\n++++++++++++++++++ un-mounting NAS drive ++++++++++++++++++++"

	sleep 0.5
	sudo umount /dev/disk/by-uuid/$1

}


mount_drive_by_uuid() {
	# mount partion $1 at $2

	printf "\n\n++++++++++++++++++ mounting NAS drive ++++++++++++++++++++"

	sleep 0.5

	# check if folder exits
	if [ -d "$2" ]; then
		echo "mount location exists"
	else
		echo "mount location does not exist. creating it ..."
		sudo mkdir $2
	fi

	echo "now mounting..."
	sudo mount -t auto /dev/disk/by-uuid/$1 $2

}


install_samba() {
	printf "\n\n++++++++++++++++++ installing samba ++++++++++++++++++++"

	sleep 0.5
	sudo apt-get install samba samba-common-bin -y
}


remove_samba() {
	printf "\n\n++++++++++++++++++ removing samba ++++++++++++++++++++"

	sleep 0.5
	sudo apt-get remove samba --purge -y

	sudo apt-get purge samba-common -y

	echo "deleting any left-over samba files..."
	sudo rm -rfv /etc/samba

}


unmake_my_NAS_drive() {

	printf "\n\n++++++++++++++++++ unmake NAS drive ++++++++++++++++++++"

	echo "stoping all processes started by NAS user.."
	sudo killall -9 -u $NAS_USER

	echo "deleting user and its home dir..."
	sudo deluser --remove-home $NAS_USER

	# remove samba, will salso remove samba users.
	remove_samba

	echo "unmount partition using UUID"
	unmount_drive_by_uuid $HDD_UUID

    # remove ntfs drivers
    remove_ntfs_drivers

	# remove extra packs
	sudo apt-get autoremove -y
	sudo apt-get autoclean -y

	# make changes to fstab for automount
	clean_fstab

}


add_new_samba_user() {

	printf "\n\n++++++++++++++++++ adding new samba user ++++++++++++++++++++"
	# $1 -> user, $2 -> pass

	echo "Samba Username: $1"
	echo "Samba Password: $2"

	(echo $2; echo $2) | sudo smbpasswd -a $1 -s


}


add_new_linux_user() {

	printf "\n\n+++++++++++++ adding new linux user in group 'user' +++++++++++++++"
	echo "Linux Username: $1"
	echo "Linux Password: $2"

	sudo useradd $1 -m -G users
	echo "setting password for the new user that was created..."
	sudo usermod --password $(echo "$2" | openssl passwd -1 -stdin) $1

}


make_my_NAS_drive() {

	printf "\n\n+++++++++++++ making NAS drive +++++++++++++++"
	# make sure you have ntfs partition
	# use NTFS so you can use it
	install_ntfs_drivers

	# install samba requirements
	install_samba

	# unmount partition using UUID
	unmount_drive_by_uuid $HDD_UUID

	# mount partition at mount location
	mount_drive_by_uuid $HDD_UUID $MOUNT_AT

	# make changes to samba config

	# check if current samba config was previously changed
	if grep -Fxq "$NAS_NAME" /etc/samba/smb.conf; then
		echo "current samba config was modified for NAS."
		echo "replace current config with a clean old one."
		sudo cp -f /etc/samba/smb.conf.clean_old  /etc/samba/smb.conf

		echo "applying NAS config to clean samba config..."
		echo "$NAS_SAMBA_CONFIG" | sudo tee --append /etc/samba/smb.conf


	else
		echo "current samba config is clean."
		echo "making backup of clean samba config."
		sudo cp -f /etc/samba/smb.conf /etc/samba/smb.conf.clean_old

		echo "applying NAS config to clean samba config..."
		echo "$NAS_SAMBA_CONFIG" | sudo tee --append /etc/samba/smb.conf

	fi

	#add linux user
	add_new_linux_user $NAS_USER $NAS_USER_PASS

	# echo "adding NAS user as a legitimate Samba user..."
	add_new_samba_user $NAS_USER $NAS_USER_PASS

	echo "giving the user read-write permissions for mount point..."
	sudo chown -R $NAS_USER:users $MOUNT_AT

	echo "restarting samba server..."
	sudo /etc/init.d/samba restart

    # make changes to fstab for automount
    add_HDD_to_fstab_by_uuid
}


############ MAIN ###########
if [ "$1" = "--install" ]; then
	make_my_NAS_drive

elif [ "$1" = "--remove" ]; then
	unmake_my_NAS_drive
else
	echo "\ninvalid usage!\n"
	echo "usage: \nsh nas_setup.sh --install\n"
	echo "or\n"
	echo "sh nas_setup.sh --remove\n"
fi
