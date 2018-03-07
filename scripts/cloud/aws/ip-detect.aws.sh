#!/bin/sh
IFS=""
IP_ADDRESS=''

cloudList=(
       '/usr/bin/curl -m 1 -fsSL http://169.254.169.254/latest/meta-data/local-ipv4 2> /dev/null'
       '/usr/bin/curl -m 1 -fsSl -H "Metadata-Flavor: Google" http://169.254.169.255/computeMetadata/v1/instance/network-interfaces/0/ip 2> /dev/null'
       '/usr/bin/curl -m 1 -fsSL -H "Metadata:true" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-04-02&format=text" 2> /dev/null'
)

for i in ${cloudList[@]};
do
   IP_ADDRESS=$(sh -c ${i});
   if [[ $? -eq 0 ]]; then echo -n $IP_ADDRESS; exit 0; fi
done
