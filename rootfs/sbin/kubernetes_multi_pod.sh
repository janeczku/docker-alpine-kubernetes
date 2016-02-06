#!/bin/ash

# Program that changes the systems primary nameserver to 127.0.0.1
# and restores the original resolv.conf on exit

RESOLV=/etc/resolv.conf
BACKUP=/etc/resolv.conf.orig

clean_up() {
	if [ -f "$BACKUP" ]
	then
		cat $BACKUP > $RESOLV
		echo "[Alpine-Kubernetes] Restored resolv.conf"
	fi
   exit
}

trap clean_up SIGHUP SIGINT SIGTERM

echo "[Alpine-Kubernetes] Changed nameserver to 127.0.0.1"

if [ ! -f "$RESOLV" ]
then
	echo "Could not stat $RESOLV"
	exit 1
fi

cp $RESOLV $BACKUP

echo '# Created by Alpine-Kubernetes' > $RESOLV
echo 'nameserver 127.0.0.1' >> $RESOLV

tail -f /dev/null