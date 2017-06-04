#!/usr/bin/env bash

# By RYN ( ariyan.eghbal@gmail.com )
# Requires: 
#	sshpass: behind NAT machine
#	netcat: both machines
#
# https://github.com/RYNEQ/Firewall-Port-Scanner.git


hash sshpass 2>/dev/null || { echo >&2 "This script requires \"sshpass\" program but it's not installed.  Aborting."; exit 1; }
hash netcat 2>/dev/null || { echo >&2 "This script requires \"netcat\" program but it's not installed.  Aborting."; exit 1; }


port_start=1024
port_end=10000
sudopart=""
timeout=5

usage() { echo "Usage: $0 host [-u <username>] [-p password] [-s start_port] [-e end_port] [-t testtimeout]" 1>&2; exit 1; }

if (("$#" < 1)); then
	usage
fi

host=$1; shift

while getopts ":u:p:s:e:t:" o; do
    case "${o}" in
        u)
            username=${OPTARG}
            ;;
        p)
            password=${OPTARG}
            ;;
	s)
	    port_start=${OPTARG}
	    ;;
	e)
	    port_end=${OPTARG}
	    ;;
	t)
	    timeout=${OPTARG}
	    ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


if [ ! "$username" ]; then
	username=$(whoami)
fi

if [ ! "$password" ]; then
	echo -n "Password for $username@$host: "
	read -s password
	echo ""
fi

if [ ! "$password" ]; then
	echo "No password! Aborting ..."
	exit 1;
fi



sshpass -p "$password" ssh $username@$host "which netcat > /dev/null"
if [ $? -ne 0 ]; then
	echo "This script requires \"netcat\" on remote machine; but cannot find it there! aborting."
	exit 1
fi

for p in $(seq $port_start $port_end); do
	if (("$p" <= 1024)); then
		sudopart=" echo '$password' | sudo -S "	
	else
		sudopart=""
	fi

	echo -n "Openning port $p on remote system ... "
	RES=$(sshpass -p "$password" ssh $username@$host "sh -c 'echo "$password" | sudo -S killall -s KILL netcat 2>&1; $sudopart netcat -l $p > /dev/null 2>&1 &'")	
	echo -n "[OK]"

	echo -n " Testing ... "
	nc -zw${timeout} $host $p && echo "[open]" || echo "[close]"

done
