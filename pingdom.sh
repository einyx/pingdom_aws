#!/bin/sh

usage() {
      echo "Usage: $0 group port"
        exit 1

}



[[ $# -eq 0  ]] && usage
RED=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

group=$1
port=$2

out=/tmp/pingdom.xml
ips=/tmp/pingdom-ips.txt

createsg() {

}
getip() {
    echo "${green}[i] ${reset}Fetching ips..."
    curl https://my.pingdom.com/probes/feed > $out
}

splitip() {
    echo "${green}[i] ${reset}Parsing IPs..."
    grep pingdom:ip /tmp/pingdom.xml | sed -n 's:.*<pingdom\:ip>\(.*\)</pingdom\:ip>.*:\1:p' > $ips
    split -l 50 $ips /tmp/segment
}

addip() {
    echo "${green}[i] ${reset}Adding IPs to security group: $group"
    while read ip; do
        aws ec2 authorize-security-group-ingress --group-id $group --cidr $ip/32 --port $port --protocol tcp
    done < /tmp/segmentaa

    while read ip; do
        aws ec2 authorize-security-group-ingress --group-id $group1 --cidr $ip/32 --port $port --protocol tcp
    done < /tmp/segmentab
}

cleanup() {
    rm $out
    rm $ips
    rm /tmp/segmentaa
    rm /tmp/segmentab
}

cleanup
getip
splitip
addip
