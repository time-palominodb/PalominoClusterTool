#!/bin/bash
apt-get update 2> /tmp/keymissing
for key in $(grep "NO_PUBKEY" /tmp/keymissing | sed "s/. *NO_PUBKEY //") ; do
	echo -e "\nProcessing key: $key"
	gpg --keyserver subkeys.pgp.net --recv $key && \
	sudo gpg --export --armor $key | \
	apt-key add -
done

# tell config management tool I've run
echo "$0 run from `pwd` fixed apt keys" > $HOME/aptKeysFixed

