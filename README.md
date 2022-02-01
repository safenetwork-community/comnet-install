# comnet-install

community testing for the SAFE network

This is only for Ubuntu-like distros at the moment.
A script for a relative n00b to quickly get the safe cli and node binaries installed, connect to a test net and use vdash to monitor their node. 

This is nowhere near ready for use at the moment. All advice and PRs welcome



This script will install everything needed to join the SAFE network testnets for
Ubuntu like machines.

- curl
- sn_cli
- safe_network
- moreutils
- build-essential
- rust
- vdash

### Any existing SAFE installation will be DELETED  ###

 vdash is a program by @happybeing to monitor your SAFE node. https://github.com/happybeing/vdash
 Vdash requires Rust to be installed

Once everthing is installed, your node will connect to the chosen testnet and vdash will be
installed to display network and node information
