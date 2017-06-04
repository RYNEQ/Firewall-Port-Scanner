# Firewall-Port-Scanner
An Scanner bash script to check tcp connectivity between a firewalled machine and a public one

Usage
------

Usage: ./scanner.sh host [-u <username>] [-p password] [-s start_port] [-e end_port] [-t testtimeout]


... If username be ommited current username will be used
... If password be ommited script asks for password
... Default value for starting port is 1024
... Default value for ending port is 10000
... Default value for tetst timeout is 5 seconds


