#!/usr/bin/env bash

if [[ SAFE_PORT == "" ]]; then
SAFE_PORT=1200
fi
GB_ALLOCATED=5
CLI_TIMEOUT=240

COMPILE_FROM_SOURCE=false

export NEWT_COLORS='
window=,white
border=black,white
textbox=black,white
button=black,white
'

############################################## welcome message
whiptail --title "********************** SAFE NODE INSTALLER  *****************************************" --msgbox "\n
This script will install everything needed to join the SAFE network testnets for Ubuntu like machines\n
The programs lised below will be installed if required. Your root password will be required.\n
 - git                    -protocal for pulling source code
 - curl                   -fetches the SAFE applications
 - sn_cli                 -the SAFE client program
 - safe_network           -the SAFE network functionality
 - moreutils              -to idenntify your network settings
 - build-essential        -required to build vdash on top of rust
 - rust                   -Rust is a systems programming lanuage
 - vdash                  -vdash is a to monitor your SAFE node
                                                 by @happybeing\n
Any existing SAFE installation will be DELETED" 25 70



############################################## select test net provider

TEST_NET_SELECTION=$(whiptail --title "Testnet Selection" --radiolist \
"Testnet providers" 20 70 10 \
"1" "Custom Testnet" OFF \
"2" "Local Baby Fleming" OFF \
"3" "Comnet by           @josh" ON \
"4" "Dreamnet by         @dreamerchris" OFF \
"5" "Folaht IPv4 by      @folaht" OFF \
"6" "Folaht IPv6 by      @folaht" OFF \
"7" "Southnet by         @southside" OFF \
"8" "Playground official test" OFF 3>&1 1>&2 2>&3)

if [[ "$TEST_NET_SELECTION" == "1" ]]; then
SAFENET=Custom
CONFIG_URL=$(whiptail --title "Custom Testnet" --inputbox "Enter config url" 8 40 3>&1 1>&2 2>&3)
elif [[ "$TEST_NET_SELECTION" == "2" ]]; then
SAFENET=baby-fleming
CONFIG_URL=n/a
elif [[ "$TEST_NET_SELECTION" == "3" ]]; then
SAFENET=comnet
CONFIG_URL=https://sn-comnet.s3.eu-west-2.amazonaws.com/node_connection_info.config
elif [[ "$TEST_NET_SELECTION" == "4" ]]; then
SAFENET=dreamnet
CONFIG_URL=https://nx23255.your-storageshare.de/s/F7e2QaDLNC2z94z/download/dreamnet.config
elif [[ "$TEST_NET_SELECTION" == "5" ]]; then
SAFENET=folaht-ipv4
CONFIG_URL=https://link.tardigradeshare.io/s/julx763rsy2egbnj2nixoahpobgq/rezosur/koqfig/sjefolaht_ipv4_node_connection_info.config?wrap=0
elif [[ "$TEST_NET_SELECTION" == "6" ]]; then
SAFENET=folaht-ipv6
CONFIG_URL=https://link.tardigradeshare.io/s/julx763rsy2egbnj2nixoahpobgq/rezosur/koqfig/sjefolaht_node_connection_info.config?wrap=0
elif [[ "$TEST_NET_SELECTION" == "7" ]]; then
SAFENET=southnet
CONFIG_URL=https://comnet.snawaffadyke.com/southsidenet.config
elif [[ "$TEST_NET_SELECTION" == "8" ]]; then
SAFENET=playground
CONFIG_URL=https://safe-testnet-tool.s3.eu-west-2.amazonaws.com/public-node_connection_info.config
fi

whiptail --title "Node Settings/n" --yesno "Procede with node defaults ?\n
Port $SAFE_PORT
Size $GB_ALLOCATED Gb\n\n
Press Enter to procede or Esc for custom values" 16 70 

if [[ $? -eq 255 ]]; then 
SAFE_PORT=$(whiptail --title "Custom Port" --inputbox "\nEnter Port Number" 8 40 $SAFE_PORT 3>&1 1>&2 2>&3)
GB_ALLOCATED=$(whiptail --title "Custom Size" --inputbox "\nEnter Size in GB" 8 40 $GB_ALLOCATED 3>&1 1>&2 2>&3)
fi 

whiptail --title "Use Git hub release or compile from source" --yesno "\nProcede with release from git hub?\n\n\n
Press enter to procede or Esc for to compile from source" 16 70

if [[ $? -eq 255 ]]; then
COMPILE_FROM_SOURCE=true
fi

clear
sudo apt -qq update
sudo apt -qq install -y snapd build-essential moreutils
sudo apt -qq install curl -y
sudo apt -qq install git -y
sudo snap remove rustup
curl https://sh.rustup.rs -sSf | sh -s -- -y
sudo apt -qq install cargo -y
cargo install vdash

PATH=$PATH:/$HOME/.safe/cli:$HOME/.cargo/bin 

ACTIVE_IF=$( ( cd /sys/class/net || exit; echo *)|awk '{print $1;}')
LOCAL_IP=$(echo $(ifdata -pa "$ACTIVE_IF"))
PUBLIC_IP=$(echo $(curl -s ifconfig.me))
SAFE_PORT=$SAFE_PORT
VAULT_SIZE=$((1024*1024*1024*$GB_ALLOCATED))
LOG_DIR=$HOME/.safe/node/local_node
SN_CLI_QUERY_TIMEOUT=$CLI_TIMEOUT

# stop any running nodes and clear out old files
safe node killall &> /dev/null
sudo systemctl stop sn_node.service
rm -rf "$HOME"/.safe

# install safe network and node
curl -so- https://raw.githubusercontent.com/maidsafe/safe_network/master/resources/scripts/install.sh | bash
safe node install

# compile from sourse if selected
if [[ "$COMPILE_FROM_SOURCE" == "true" ]]; then
mkdir -p $HOME/.safe/github-tmp
git clone https://github.com/maidsafe/safe_network.git ~/.safe/github-tmp/
cd ~/.safe/github-tmp
cargo build --release
rm ~/.safe/cli/safe
cp ~/.safe/github-tmp/target/release/safe ~/.safe/cli/
rm ~/.safe/node/sn_node
cp ~/.safe/github-tmp/target/release/sn_node ~/.safe/node/
fi

#start safe network
if [[ "$SAFENET" == "baby-fleming" ]]; then
safe node run-baby-fleming
else
echo -n "#!/bin/bash
RUST_LOG=safe_network=trace,qp2p=info \
	~/.safe/node/sn_node \
	--max-capacity $VAULT_SIZE \
	--local-addr "$LOCAL_IP":$SAFE_PORT \
	--public-addr "$PUBLIC_IP":$SAFE_PORT \
	--skip-auto-port-forwarding \
	--log-dir "$LOG_DIR" & disown"\
| tee ~/.safe/node/start-node.sh &> /dev/null

chmod u+x ~/.safe/node/start-node.sh

echo -n "[Unit]
Description=Safe Node
[Service]
User=$USER
ExecStart=/home/$USER/.safe/node/start-node.sh
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target"\
|sudo tee /etc/systemd/system/sn_node.service &> /dev/null

sudo systemctl start sn_node.service

sleep 3

vdash "$LOG_DIR"/sn_node.log
fi
