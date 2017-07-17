# BtNasPian

This is a program that automates NAS setup. Assumes one USB HDD connected to the Raspberry Pi.
No Raid Support. Simple program for newbies.

If you are looking for a better solution with a good web interface,
 [try this](https://github.com/gurudigitalsolutions/NAS-Pi). 
 We do intend to add these features in the future.

This program is intended to be a three part solution that combines:
* NAS
* Transmission Bit Torrent (Web-Interface Daemon)
* VPN

## Instructions:

Execute the following command to install:

'''
sudo chmod +X pi_util.sh
sudo sh nas_util.sh install_and_setup_nas
'''

To remove:
'''
sudo sh nas_util.sh remove_nas
'''

For advanced users, open nas_setup.sh, change configuration variables and run.