#!/bin/bash
#
# before you do anything, please read through this file carefully  
# if you get permission denied then run "chmod +x nas_util.sh" first
#
# USAGE:
#
# sudo sh nas_util.sh [install_and_setup_nas|remove_nas]
#
# 


install_and_setup_nas() {

    # ask user for pptp configs
    sudo python3 build_nas_config.py

    # run shell script
    sudo sh nas_setup.sh --install

}


remove_nas() {

    # run shell script
    sudo sh nas_setup.sh --remove

}