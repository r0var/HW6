#!/bin/bash

ARG0=$0
ARG1=$1
ARG2=$2
ARG3=$3

function writeLog {
  local DATE="$(date +"%d %b %Y %H:%M:%S")"
  echo "$DATE $1 $$ $(whoami)" >> myscript_log
}

function findFiles {
  writeLog $FUNCNAME
  find -type f -mtime +10 -printf '%TY-%Tm-%Td %TR %p\n'  2>&1 \
    | grep -v "Permission denied" \
    | awk -F "/" '{print $NF,$0}' \
    | sort \
    | cut -f2- -d' ' \
    | sed 's/^[^/ ]*/\x1b[32m&\x1b[0m/' \
    | sed 's/[^\/]*$/\x1b[32m&\x1b[0m/'
}

function findFolders {
  writeLog $FUNCNAME
  find -type d -mtime +10 -printf '%TY-%Tm-%Td %TR %p\n'  2>&1 \
    | grep -v "Permission denied" \
    | awk -F "/" '{print $NF,$0}' \
    | sort \
    | cut -f2- -d' ' \
    | sed 's/^[^/ ]*/\x1b[31m&\x1b[0m/' \
    | sed 's/[^\/]*$/\x1b[31m&\x1b[0m/'
}

function showStatus {
  writeLog $FUNCNAME
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local BLUE='\033[0;34m'
  local PURPLE='\033[0;35m'
  local NC='\033[0m'
  local COUNT=$(ps -ef | wc | awk '{print $1 - 2}')
  local LOAD=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
  local CORES=$(nproc --all)
  local SPACE=$(df -h | grep ubuntu | awk '{print $4 }')
  local MEM=$(free | grep Mem | awk '{print $4}')
  echo -e "${GREEN}$COUNT${NC} ${RED}$LOAD $CORES${NC} ${BLUE}$MEM${NC} ${PURPLE}$SPACE${NC}"
}

function writeRecord {
  writeLog $FUNCNAME
  local CHECK=$(sudo grep "$ARG2" /etc/hosts)
  if [[ $CHECK = $ARG2 ]] 
  then
    echo "Entry exists!"
  else
    sudo sh -c "echo '$ARG2' >> /etc/hosts"
    echo "Entry added!"
  fi
}

function rewriteRecord {
  writeLog $FUNCNAME
  local CHECK=$(sudo grep "$ARG2" /etc/hosts)
  if [ ! -z "$CHECK" ]; then
  sudo sed -i "s/$CHECK/$ARG3/" /etc/hosts
  echo "Entry changed!"
  else echo "Entry not found!" 
  fi
}

function checkFolder {
  writeLog $FUNCNAME
  echo "Expecting a directory"
  while [ true ]
  do
  if [ -d "DELETE_ME" ]; then
  echo "$(date +"%S:%M:%H %d %b %Y")" >> ./DELETE_ME/temp
  break
  fi
  done
  echo "The data is written to the directory"
}

function printHelp {
  writeLog $FUNCNAME
  echo -e "   --help                              Shows help \n \
  --folders                           Search for folders older than 10 days \n \
  --files                             Search for files older than 10 days \n \
  --status                            Shows system status \n \
  --adhost [IP HOSTNAME]              Adds entry to hosts \n \
  --rwhost [HOSTNAME] [IP HOSTNAME]   Looks up the first parameter in hosts and replaces it with the second parameter\n \
  --waitd                             Waits for the 'DELETE_ME folder to appear and writes data to it"
}

case $ARG1 in
  --folders) findFolders
    echo "These are the folders found" ;;
  --files) findFiles
    echo "These are the files found" ;;
  --status) showStatus
    echo "Number of processes, 5 min average load, free memory, free space" ;;
  --adhost) writeRecord ;;
  --rwhost) rewriteRecord ;;
  --waitd) checkFolder & ;;
  --help) printHelp ;;
  *) echo "Try './myscript.sh --help' for more information." ;;
esac