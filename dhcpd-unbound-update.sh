#!/usr/bin/env bash

ubctl="/usr/local/sbin/unbound-control"

if [ $# -lt 4 ]; then
	echo "Invalid args"
	exit 1
fi

event=$1
client_ipaddr=$2
client_hostname=$3
dns_zone=$4

case "$event" in
	commit)
		echo "Would run: $ubctl local_data \"$client_hostname.$dns_zone IN A $client_ipaddr\""
	;;
	release)
	;&
	expiry)
		echo "Would run: $ubctl local_data_remove \"$client_hostname.$dns_zone\""
	;;
	*)
		echo "Unknown event type."
		exit 1
esac

