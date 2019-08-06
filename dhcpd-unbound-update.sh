#!/usr/local/bin/bash

set -x

# This script handles addition and deletion of Unbound local_data records when
# executed by isc-dhcpd's 'on commit|release|expiry' events.
#
# The following parameters are expected:
# 1. Event type ('commit', 'release' or 'expiry')
# 2. Hostname of dhcp client
# 3. IP address leased to client
# 4. Domain to add/remove record to

logfile=/tmp/dhcpd-unbound-update.log

ubctl="/usr/local/sbin/unbound-control"

if [ $# -lt 4 ]; then
	echo "Invalid args"
	exit 1
fi

event=$1
client_ipaddr=$2
client_hostname=$3
dns_zone=$4

# Sanitise hostname as it may contain illegal characters for DNS records
# Replace spaces with underscores
client_hostname=${client_hostname// /-}
# Remove anything non-alphanumerical or hyphen
client_hostname=${client_hostname//[^a-zA-Z0-9-]/}
# Convert to lowercase
client_hostname=${client_hostname,,}

echo "Sanitised hostname: $client_hostname" >> $logfile

case "$event" in
	commit)
		$ubctl local_data $client_hostname.$dns_zone IN A $client_ipaddr 2>&1
		exit 0
	;;
	release)
	;&
	expiry)
		$ubctl local_data_remove $client_hostname.$dns_zone
		exit 0
	;;
	*)
		echo "Error: Unknown event type."
		exit 1
esac
