#!/bin/bash

echo "--------------------------------------------------------------------------------------"
echo ""
echo "This script will install everything needed to join the SAFE network testnets for Ubuntu "
echo ""
echo " any existing SAFE installation will be DELETED"
echo " vdash is a program by @happybeing to monitor your SAFE node."
echo " Rust will be installed if necessary"
echo ""
echo "OK to proceed [Y,n]"
read input

if [[ $input == "Y" || $input == "y" ]]; then
        echo "OK then..."
else
       echo "Bye now..."
       
       exit
fi


read -p " Enter the vault size in Gb [ default 5Gb]: " VAULT_SIZE
VAULT_SIZE=${VAULT_SIZE}
echo $VAULT_SIZE "Gb will be allocated for storing chunks"


sudo apt update
sudo apt install snapd build-essential
sudo snap install curl

#exit 

LOCAL_IP=$(echo `ifdata -pa enp5s0`)
PUBLIC_IP=$(echo `curl -s ifconfig.me`)
SAFE_PORT=12000
SAFENET=folaht
CONFIG_URL=https://link.tardigradeshare.io/s/julx763rsy2egbnj2nixoahpobgq/rezosur/koqfig/sjefolaht_node_connection_info.config?wrap=0
#CONFIG_URL=https://sn-comnet.s3.eu-west-2.amazonaws.com/node_connection_info.config
MAX_NODE_CAPACITY=$(numfmt --from auto 5Gi)
LOG_DIR=$HOME/.safe/node/local_node





# Install Safe software and configuration

rm -rf $HOME/.safe
curl -so- https://raw.githubusercontent.com/maidsafe/safe_network/master/resources/scripts/install.sh | bash

echo "SAFE CLI install completed"
safe --version


safe node install
echo "SAFE Node install completed"


PATH=$PATH:/$HOME/.safe/cli:$HOME/.cargo/bin 
safe networks check
safe networks add $SAFENET $CONFIG_URL
safe networks switch $SAFENET
safe networks
sleep 1
export SN_CLI_QUERY_TIMEOUT=3600

# Join a node from home

echo "Attempting to join the network using the following parameters"
echo ""
echo ""
echo "--max-capacity" $MAX_NODE_CAPACITY
echo "--local-addr" $LOCAL_IP":"$SAFE_PORT
echo $LOCAL_IP


RUST_LOG=safe_network=trace \
    ~/.safe/node/sn_node \
    --max-capacity $MAX_NODE_CAPACITY \
    --local-addr $LOCAL_IP:$SAFE_PORT \
    --public-addr $PUBLIC_IP:$SAFE_PORT \
    --skip-auto-port-forwarding \
    --log-dir $LOG_DIR

#clear
echo "_____________________________________________________________________________________________________"
echo ""
echo "                    Now installing rust and vdash from @happybeing"
echo ""
echo ""
echo "       press 'q' to quit vdash     --- this will not interfere with your node ---"

echo  ""

sleep 3



# Install or update vdash
sudo snap install rustup --classic
rustup toolchain install stable
cargo install vdash
vdash $LOG_DIR/sn_node.log


echo "-----------------------------   Getting Started   -----------------------------------------------------------"
echo " SAFE network files have been installed and configured. You can now use the *safe files put* command to upload files to the network." 
echo "Append *-r* if you want to upload a directry full of files and any sub-directories. "
echo " See https://github.com/maidsafe/sn_cli#files-put for more details"
echo
echo
echo
echo " more getting started info will be posted shortly. Keep checking back on Github for the latest" 


