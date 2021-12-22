#!/bin/bash

# script to set up comnet - community testing for the SAFE network

#============================  TO DO  =====================================
# add warnings
# Add a Getting Started section after script completes - quiick instructions on files put and get, cat and dog

#=================================================================================
echo "================================================================================================"
echo "This script is only for 'vanilla' linux systems on standard x86-64 PC hardware"
echo " A Windows version is in work. Thank you for your patience."
echo 
echo
#PUBLIC_IP=$(echo `curl -s ifconfig.me`)
#NODE_PORT= #TO DO      if we set the same port for everyone, what happens? 
TMP_DIR=/tmp/comnet
SAFE_ROOT=/home/$USER/.safe
NODE_BIN_PATH=$SAFE_ROOT/node
SAFE_BIN_PATH=$SAFE_ROOT/sn_cli
LOG_DIR_PATH=$SAFE_ROOT/logs
COMNET_CONN_INFO=https://sn-comnet.s3.eu-west-2.amazonaws.com/node_connection_info.config

SN_CLI_QUERY_TIMEOUT=180
RUST_LOG=safe_network=info,qp2p=info   

echo "This script will install comnet - community testing for the SAFE network"
echo "comnet files will be installed in "$SAFE_ROOT
echo "log files will be stored in "$LOG_DIR_PATH
#echo "data files will be stored in "$DATA_DIR_PATH
echo
echo
echo "Your public IP address is " $PUBLIC_IP
echo

# clean up from last testnet
rm -rf $SAFE_ROOT

# get sn_cli
cd
curl -so- https://install-safe.s3.eu-west-2.amazonaws.com/install.sh | bash
safe node install

# set up the network
safe networks add comnet $COMNET_CONN_INFO
safe networks switch comnet
safe networks check
safe networks
