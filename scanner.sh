#!/usr/bin/env bash

# By RYN ( ariyan.eghbal@gmail.com )
# Requires: 
#	sshpass: behind NAT machine
#	netcat: both machines
#
# https://github.com/RYNEQ/Firewall-Port-Scanner.git

host=""
user=""
password=""
start=1024
end=10000
sudopart=""

if (("$#" < 2)); then
		echo <<EOF
	Usage $0 host.tld username [password] [start] [end]
		username: a valid username 
			if scanning ports below 1024 the username must be a sudoer otherwise only ports with active service are scanned and the rest are detected as closed.
		
		password: valid password for the \$username
			if this option be omitted the password will be asked from user
		
		start: starting port number (default: 1024)
		end: ending port number (default: 10000)
EOF

		exit 1
fi

host=$1
user=$2

if (("$#" < 3)); then
	echo -n "Password: "
	read -s password
	echo ""
else
	password=$3
fi

if (("$#" > 3)); then
	start=$4
fi
if (("$#" > 4)); then
	end=$5
fi


for p in $(seq $start $end); do
	if (("$p" <= 1024)); then
		sudopart=" echo '$password' | sudo -S "	
	else
		sudopart=""
	fi

	echo -n "Openning port $p on remote system ... "
	RES=$(sshpass -p "$password" ssh $user@$host "sh -c 'echo "$password" | sudo -S killall -s KILL netcat 2>&1; $sudopart netcat -l $p > /dev/null 2>&1 &'")	
	echo -n "[OK]"

	echo -n " Testing ... "
	nc -zw5 $host $p && echo "[open]" || echo "[close]"

done
