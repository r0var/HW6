#!/bin/bash

function getData {

TIME=$(date +"%S:%M:%H %d %b %Y")
MEM=$(free | grep Mem | awk '{print $4}')
CPU1=$(lscpu | grep name | awk -F" " '{print $3 " " $4 " " $6 " " $8}')
CPU2=$(lscpu | grep Architecture | awk '{print $2}')
LOAD=$(uptime | awk -F",  " '{print $3}')
SPACE=$(df -h | grep ubuntu | awk '{print $4 }')

}

function printData {

getData
echo $TIME memory:$MEM $CPU1 $CPU2 $LOAD space:$SPACE

}

while [ true ]
do
printData >> /var/log/custom_daemon.log
sleep 30
done
