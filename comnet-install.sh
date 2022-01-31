#!/usr/bin/env bash

echo "--------------------------------------------------------------------------------------"
echo ""
echo "This script will install everything needed to join the SAFE network testnets for"
echo "Ubuntu like machines"
echo ""
echo " Any existing SAFE installation will be DELETED"
echo ""
echo " vdash is a program by @happybeing to monitor your SAFE node. https://github.com/happybeing/vdash"
echo " Vdash requires Rust to be installed"
echo ""
echo "OK to proceed [y,N]"
read input

if [[ $input == "Y" || $input == "y" ]]; then
        echo "OK then, let's go."
else
       echo "Bye now..."
       
       exit
fi

read -p " Enter the vault size in Gb [5Gb]: " GB_ALLOCATED
VAULT_SIZE=${GB_ALLOCATED:-5}
echo $VAULT_SIZE "Gb will be allocated for storing chunks"
ip a > /tmp/ipa.txt
ACTIVE_IF=`grep "2: " /tmp/ipa.txt|cut -f2 -d':'|cut -c2-`

#Install the dependencies
sudo apt -qq update
sudo apt -qq install -y snapd build-essential moreutils
sudo snap install curl
PATH=$PATH:/$HOME/.safe/cli:$HOME/.cargo/bin 
ACTIVE_IF=$(ip a |grep "2: " | awk -F ":" '{ print $2 }' | xargs)
LOCAL_IP=$(echo `ifdata -pa $ACTIVE_IF`)
PUBLIC_IP=$(echo `curl -s ifconfig.me`)
SAFE_PORT=12000
SAFENET=folaht
CONFIG_URL=https://link.tardigradeshare.io/s/julx763rsy2egbnj2nixoahpobgq/rezosur/koqfig/sjefolaht_node_connection_info.config?wrap=0
#CONFIG_URL=https://sn-comnet.s3.eu-west-2.amazonaws.com/node_connection_info.config
VAULT_SIZE=$((1024*1024*1024*$GB_ALLOCATED))
LOG_DIR=$HOME/.safe/node/local_node


# Install Safe software and configuration
# clear out any old files
rm -rf $HOME/.safe

#get the CLI
curl -so- https://raw.githubusercontent.com/maidsafe/safe_network/master/resources/scripts/install.sh | bash
echo "SAFE CLI install completed"
safe --version
#PATH=$PATH:/$HOME/.safe/cli:$HOME/.cargo/bin 
#safe networks check
safe networks add $SAFENET $CONFIG_URL
safe networks switch $SAFENET
safe networks
sleep 3
SN_CLI_QUERY_TIMEOUT=3600

safe node install
echo "SAFE Node install completed"

# Join a node from home

RUST_LOG=safe_network=trace \
    ~/.safe/node/sn_node \
    --max-capacity $VAULT_SIZE \
    --local-addr $LOCAL_IP:$SAFE_PORT \
    --public-addr $PUBLIC_IP:$SAFE_PORT \
    --skip-auto-port-forwarding \
    --log-dir $LOG_DIR    
    
echo "Attempting to join the '$SAFENET' network using the following parameters"
echo ""
echo "--max-capacity" $VAULT_SIZE
echo "--local-addr" $LOCAL_IP":"$SAFE_PORT
echo "--public-addr" $PUBLIC_IP":"$SAFE_PORT
echo "--log-dir" $LOG_DIR
echo "--skip-auto-port-forwarding"

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

