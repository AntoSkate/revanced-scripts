#!/bin/bash

# Set script arguments
operation=$1
apk=$2
parameters=$3

# Create functions
get_adb_device() {
	adb start-server
	adb="$(adb devices | grep '[[:graph:]]')"
	adb="${adb:24:-7}"
}
mount() {
	get_adb_device
	java -jar revanced-cli-all.jar patch -b revanced-patches.jar -d $adb -e "GmsCore support" -m revanced-integrations.apk --mount -o out.apk -p $parameters $apk
}
unmount() {
	get_adb_device
	java -jar revanced-cli-all.jar utility uninstall -p $apk -u $adb
}
install() {
	get_adb_device
	java -jar revanced-cli-all.jar patch -b revanced-patches.jar -d $adb -m revanced-integrations.apk -o out.apk -p $parameters $apk
}
apk() {
	java -jar revanced-cli-all.jar patch -b revanced-patches.jar -m revanced-integrations.apk --mount -o out.apk -p $parameters $apk
}

# Update ReVanced files
if [[ ! -f version.json ]]
then
	echo -e '{\n\t"cli": "",\n\t"patches": "",\n\t"integrations": ""\n}' > version.json
fi

for repo in "cli 9 -2 revanced-cli-all.jar revanced-cli- -all.jar" "patches 13 -2 revanced-patches.jar revanced-patches- .jar" "integrations 18 -1 revanced-integrations.apk revanced-integrations- .apk"
do
	set $repo

	oldversion="$(grep "$1" version.json)"
	oldversion="${oldversion:$2:$3}"

	version="$(curl -s https://api.revanced.app/v2/revanced-$1/releases/latest?dev=true | grep -Eo '"tag_name":"[^"]*+"')"
	version="${version:13:-1}"

	file="$5"$version"$6"

	if [[ $oldversion != $version ]]
	then
		if [[ -f $4 ]]
		then
			rm $4
		fi

		echo "---> Downloading $1 version $version <---"
		curl -s -L "https://github.com/revanced/revanced-$1/releases/download/v$version/$file" -o $4
	fi

	export $1=$version
done

$(echo -e "{\n\t\"cli\": \"$cli\",\n\t\"patches\": \"$patches\",\n\t\"integrations\": \"$integrations\"\n}" > version.json)

# Patch apk
for valid_operation in mount unmount install apk
do
	if [[ "$operation" == "$valid_operation" ]]
	then
		$operation
		break
	fi
done
