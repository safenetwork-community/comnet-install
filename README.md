# comnet-install

community testing for the SAFE network

This is only for Ubuntu-like distros at the moment.
A script for a relative n00b to quickly get the safe cli and node binaries installed, connect to a test net and use vdash to monitor their node. 

All advice and PRs are very welcome.



This script will install everything needed to join the SAFE network testnets for
Ubuntu like machines. The minimum amount of configuration will be done to get a working solution.
The script will also install filebeat  https://www.elastic.co/beats/filebeat to allow sending logs to a central ELK server for analysis by maidsafe devs

The following packages will be installed/updated if they do not already exist on the target machine

- curl
- sn_cli
- safe_network
- moreutils
- build-essential
- rust
- vdash
- filebeat

### Any existing SAFE installation will be DELETED  ###

 vdash is a program by @happybeing to monitor your SAFE node. https://github.com/happybeing/vdash
 Vdash requires Rust to be installed

Once everthing is installed, your node will connect to the chosen testnet and vdash will be
installed to display network and node information
