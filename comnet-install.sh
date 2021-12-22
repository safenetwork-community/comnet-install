#!/bin/bash

# script to set up comnet - community testing for the SAFE network

#============================  TO DO  =====================================
# make paths configurable
# add warnings
# Add a Getting Started section after script completes - quiick instructions on files put and get, cat and dog
# if we set the same port for everyone, what happens? 
# write a Powershell script to set up a Linux VM for Windows users
#=================================================================================
echo "================================================================================================"
echo "This script is only for 'vanilla' linux systems on standard x86-64 PC hardware"
echo " A Windows version is in work. Thank you for your patience."
echo 
echo
PUBLIC_IP=$(echo `curl -s ifconfig.me`)
NODE_PORT= #TO DO      if we set the same port for everyone, what happens? 
TMP_DIR=/tmp/comnet
SAFE_ROOT=/home/$USER/.safe
NODE_BIN_PATH=$SAFE_ROOT/node
SAFE_BIN_PATH=$SAFE_ROOT/sn_cli
LOG_DIR_PATH=$SAFE_ROOT/logs
COMNET_CONN_INFO=https://sn-comnet.s3.eu-west-2.amazonaws.com/node_connection_info.config
#SN_NODE_ASSET=https://github.com/maidsafe/safe_network/releases/download/safe_network-v0.51.7/sn_node-0.51.7-x86_64-unknown-linux-musl.tar.gz
#DATA_DIR_PATH=$SAFE_ROOT/data_dir
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

# Add a node
safe node join \
--skip-auto-port-forwarding \

--public-addr $PUBLIC_IP:34567     #Placeholder for now
#--public-addr $PUBLIC_IP:$NODE_PORT
# --log-dir $LOG_DIR_PATH \
