#!/usr/bin/env bash
# https://github.com/safenetwork-community
# safenetwork-community  
echo "********************** SAFE NODE INSTALLER  *****************************************"
echo ""
echo ""
echo ""
echo ""
echo "This script will install everything needed to join the SAFE network testnets for"
echo "Ubuntu like machines"
echo ""
echo " Any existing SAFE installation will be DELETED"
echo ""
echo " vdash is a program by @happybeing to monitor your SAFE node. https://github.com/happybeing/vdash"
echo " Vdash requires Rust to be installed"
echo ""
echo "Once everthing is installed, your node will connect to the chosen testnet and vdash will be"
echo "installed to display network and node information"
echo ""
echo ""
echo "OK to proceed [y,N]"
read -r input

if [[ $input == "Y" || $input == "y" ]]; then
        echo "OK then, let's go."
else
       echo "Bye now..."     
       exit
fi

read -p -r " How many GB do you want to allocate to your vault? [5 GB]: " GB_ALLOCATED
VAULT_SIZE=${GB_ALLOCATED:-5}
echo "$VAULT_SIZE" "GB will be allocated for storing chunks"
echo "_________________________________________________________"

sudo apt -qq update >/dev/null
sudo apt -qq install -y snapd build-essential moreutils >/dev/null
sudo snap install curl

PATH=$PATH:/$HOME/.safe/cli:$HOME/.cargo/bin 

ACTIVE_IF=$( ( cd /sys/class/net || exit; echo *)|awk '{print $1;}')
LOCAL_IP=$(echo $(ifdata -pa "$ACTIVE_IF"))
PUBLIC_IP=$(echo $(curl -s ifconfig.me))
SAFE_PORT=12000
SAFENET=southsidenet
#CONFIG_URL=https://link.tardigradeshare.io/s/julx763rsy2egbnj2nixoahpobgq/rezosur/koqfig/sjefolaht_node_connection_info.config?wrap=0
#CONFIG_URL=https://sn-comnet.s3.eu-west-2.amazonaws.com/node_connection_info.config
VAULT_SIZE=$((1024*1024*1024*$GB_ALLOCATED))
LOG_DIR=$HOME/.safe/node/local_node
SN_CLI_QUERY_TIMEOUT=3600

# Install Safe software and configuration

rm -rf "$HOME"/.safe # clear out any old files

#get the CLI
curl -so- https://raw.githubusercontent.com/maidsafe/safe_network/master/resources/scripts/install.sh | bash
echo $(safe --version) "install complete"

safe networks add $SAFENET "$CONFIG_URL"
safe networks switch $SAFENET
safe networks
sleep 2
safe node install
echo $(safe node bin-version) "install complete"


echo "SAFE Node install completed"

# Join a node from home

echo "Attempting to join the '$SAFENET' network using the following parameters"
echo ""
echo "--max-capacity" $VAULT_SIZE
echo "--local-addr" "$LOCAL_IP"":"$SAFE_PORT
echo "--public-addr" "$PUBLIC_IP"":"$SAFE_PORT
echo "--log-dir" "$LOG_DIR"
echo "--skip-auto-port-forwarding"

RUST_LOG=safe_network=trace,qp2p=info \
    ~/.safe/node/sn_node \
    --max-capacity $VAULT_SIZE \
    --local-addr "$LOCAL_IP":$SAFE_PORT \
    --public-addr "$PUBLIC_IP":$SAFE_PORT \
    --skip-auto-port-forwarding \
    --log-dir "$LOG_DIR"    

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
vdash "$LOG_DIR"/sn_node.log
