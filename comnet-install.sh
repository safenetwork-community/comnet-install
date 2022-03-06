#!/usr/bin/env bash
# https://github.com/safenetwork-community
# safenetwork-community  

##
# Color  Variables
##
red='\e[31m'
green='\e[32m'
blue='\e[34m'
clear='\e[0m'

##
# Color Functions
##

ColorGreen(){
	echo -  $green$1$clear
}
ColorBlue(){
	echo -  $blue$1$clear
}
ColorRed(){
	echo -  $red$1$clear
}

clear
echo  "********************** SAFE NODE INSTALLER  *****************************************"
echo ""
echo ""
echo ""
echo ""
echo  "    This script will install everything needed to join the SAFE network testnets for "
echo  "    Ubuntu like machines"
echo  "    The programs lised below will be installed if required. Your root password will be required."
echo ""
echo ""
echo " - snap                   -assists in installin the dependencies"
echo " - curl                   -fetches the SAFE applications"
echo " - sn_cli                 -the SAFE client program  "
echo " - safe_network           -the SAFE network functionality "
echo " - moreutils              -helper programs to assist in idenntifying your network settins"
echo " - tree                   -needed to show the ~/.safe directory structure"
echo " - build-essential        -required to build vdash on top of rust "
echo " - rust                   -Rust is a systems programming lanuage   "
echo " - vdash                  -vdash is a Rust program by @happybeing to monitor your SAFE node  "
echo ""
echo ""
echo ""
echo -ne $(ColorRed " ################# Any existing SAFE installation will be DELETED ##################")
echo ""
echo ""
echo ""
echo ""
echo "             Once everything is installed, your node will connect to the chosen testnet and vdash will be"
echo "                             configured to display network and node information"
echo ""
echo ""
echo "                If you are happy with the above and have read the Readme, type 'y' to proceed [y,N]"
read -r input

if [[ $input == "Y" || $input == "y" ]]; then
        echo "                            OK then, let's go."
else
       echo "Bye now..."     
       exit
fi

echo "           Which testnet do you want to connect to?"

echo ""
echo "           None of these testnets are guaranteed or even likely to be running at any given time"
echo "           Please refer to threads on https://safenetforum.org for current news on live testnets."

echo ""
echo "               1     sjefolaht"
echo "               2     comnet"
echo "               3     southsidenet"
echo "               4     playground"
echo ""
echo ""
echo "                                    Please select 1, 2, 3 or 4"
read SAFENET_CHOICE
echo ""

case $SAFENET_CHOICE in

  1)
  SAFENET=sjefolaht
  CONFIG_URL=https://link.tardigradeshare.io/s/julx763rsy2egbnj2nixoahpobgq/rezosur/koqfig/sjefolaht_node_connection_info.config?wrap=0
    
    ;;

  2)  SAFENET=comnet
    CONFIG_URL=https://sn-comnet.s3.eu-west-2.amazonaws.com/node_connection_info.config
    ;;

  3)
  SAFENET=southsidenet
    CONFIG_URL=https://comnet.snawaffadyke.com/southsidenet.config

    ;;

    4)
  SAFENET=playground
    CONFIG_URL=https://safe-testnet-tool.s3.eu-west-2.amazonaws.com/public-node_connection_info.config

    ;;
    
  *)
    echo " Invalid selection, please choose 1-4 to select a testnet"
    ;;
esac

echo ""
echo "                    Your node will attempt to connect to "$SAFENET
echo "" 
echo "                   For some testnets, it will be necessary to allocate a fixed size for your vault."
echo "                   Again please refer to threads on https://safenetforum.org for details. If no size"
echo "                   is specified, 5GB will be selected as default."
  
GB_ALLOCATED=5
read -e -i "$GB_ALLOCATED" -p '                   How many GB do you want to allocate to your vault? [5]' GB_ALLOCATED
VAULT_SIZE=${GB_ALLOCATED}
echo "                   $VAULT_SIZE" "GB will be allocated for storing chunks"
echo ""
echo ""
echo ""
echo ""
echo "              Certain setups may require the default SAFE port to be changed"
echo "              Almost all users will be OK with the default port at 12000 "
echo "              Only change this if you really know what you are doing."
echo ""

SAFE_PORT=12000
read -e -i "$name" -p "              Press Enter to accept the default or edit it here $SAFE_PORT    " input
SAFE_PORT="${input:-$SAFE_PORT}"
echo $SAFE_PORT
echo ""
echo ""
echo ""
echo ""

sleep 2

echo ""
echo ""
echo ""
echo ""
echo "              Now installing SAFE and all necessary dependencies."
echo "              This may take a few minutes depending on your download speed  "
echo "              Thank you for your patience  "
echo ""
echo -ne $(ColorBlue "            The world has waited a long time for SAFE - just a few seconds more....")
echo ""
echo ""
echo ""
echo ""
echo "                           Please ignore warning about apt"
echo ""

TMP_GH_DIR=$HOME/github-tmp

rm -rf "$HOME"/.safe # clear out any old files

if [[ -d "$TMP_GH_DIR" ]]
then
    rm -rf $TMP_GH_DIR
fi

sudo apt -qq update >/dev/null
sudo apt -qq install -y snapd build-essential moreutils tree >/dev/null
sudo snap install curl
sudo snap install rustup --classic
rustup toolchain install stable

mkdir -p \
	$TMP_GH_DIR \
	$HOME/.safe/cli \
	$HOME/.safe/node

PATH=$PATH:/$HOME/.safe/cli:$HOME/.cargo/bin   

git clone https://github.com/maidsafe/safe_network.git $TMP_GH_DIR
cd ~/github-tmp
cargo build --release
cp $TMP_GH_DIR/target/release/safe ~/.safe/cli/
cp $TMP_GH_DIR/target/release/sn_node ~/.safe/node/
echo $(safe --version) "CLI install complete"
echo $(safe node bin-version) "Node install complete"
sleep 2

tree  $HOME/.safe
sleep 3

cargo install vdash

ACTIVE_IF=$( ( cd /sys/class/net || exit; echo *)|awk '{print $1;}')
LOCAL_IP=$(ifdata -pa "$ACTIVE_IF")
PUBLIC_IP=$(curl -s ifconfig.me)
SAFE_PORT=$SAFE_PORT
VAULT_SIZE=$((1024*1024*1024*$GB_ALLOCATED))
LOG_DIR=$HOME/.safe/node/local_node
SN_CLI_QUERY_TIMEOUT=3600

# Install Safe software and configuration

#get the CLI
#curl -so- https://raw.githubusercontent.com/maidsafe/safe_network/master/resources/scripts/install.sh | bash
#safe node install
echo ""
echo ""
echo ""

safe networks add $SAFENET "$CONFIG_URL"
safe networks switch $SAFENET
safe networks
sleep 2

echo ""
echo ""
echo ""
echo $(safe node bin-version) "install complete"

# Join a node from home

echo "Attempting to join the '$SAFENET' network using the following parameters"
echo ""
echo "--max-capacity" $VAULT_SIZE
echo "--local-addr" "$LOCAL_IP"":"$SAFE_PORT
echo "--public-addr" "$PUBLIC_IP"":"$SAFE_PORT
echo "--log-dir" "$LOG_DIR"
echo "--skip-auto-port-forwarding"

# start as service 

safe node killall
sudo systemctl stop sn_node.service
	
echo -n "#!/bin/bash
RUST_LOG=safe_network=trace,qp2p=info \
	~/.safe/node/sn_node \
	--max-capacity $VAULT_SIZE \
	--local-addr "$LOCAL_IP":$SAFE_PORT \
	--public-addr "$PUBLIC_IP":$SAFE_PORT \
	--skip-auto-port-forwarding \
	--log-dir "$LOG_DIR" & disown"\
| tee ~/.safe/node/start-node.sh

chmod u+x ~/.safe/node/start-node.sh
	
echo -n "[Unit]
Description=Safe Node
[Service]
User=$USER
ExecStart=/home/$USER/.safe/node/start-node.sh
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target"\
|sudo tee /etc/systemd/system/sn_node.service

sudo systemctl start sn_node.service
#sudo systemctl status sn_node.service

#clear
echo "_____________________________________________________________________________________________________"
echo ""
echo "                    Now cofiguring vdash from @happybeing"
echo ""
echo ""
echo "       press 'q' to quit vdash     --- this will not stop your node ---"
echo ""
echo ""
echo "    You can cycle through different Safe nodes using left/right arrow keys, and zoom the timeline scale in/out using 'i' and 'o' (or '+' and '-')."
echo ""
echo "    Feature requests and discussion are currently summarised in the opening post of the Safe Network forum topic: Node Dashboard ideas please!."
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
sleep 3

# Install or update vdash

vdash "$LOG_DIR"/sn_node.log
