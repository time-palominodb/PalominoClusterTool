#!/bin/bash

#   Copyright 2012 Tim Ellis
#   CTO: PalominoDB
#   The Palomino Cluster Tool
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

apt-get update 2> /tmp/keymissing
for key in $(grep "NO_PUBKEY" /tmp/keymissing | sed "s/. *NO_PUBKEY //") ; do
	echo -e "\nProcessing key: $key"
	gpg --keyserver subkeys.pgp.net --recv $key && \
	sudo gpg --export --armor $key | \
	apt-key add -
done

# tell config management tool I've run
echo "$0 run from `pwd` fixed apt keys" > $HOME/aptKeysFixed

