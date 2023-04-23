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
	java -jar revanced-cli-all.jar -a $apk -c -m revanced-integrations.apk -b revanced-patches.jar -o out -d $adb --mount -e vanced-microg-support -e music-microg-support $parameters
}
unmount() {
	get_adb_device
	java -jar revanced-cli-all.jar -a $apk -d $adb --uninstall
}
install() {
	get_adb_device
	java -jar revanced-cli-all.jar -a $apk -c -m revanced-integrations.apk -b revanced-patches.jar -o out -d $adb $parameters
}
apk() {
	java -jar revanced-cli-all.jar -a $apk -c -m revanced-integrations.apk -b revanced-patches.jar -o out $parameters
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

	version="$(curl -s https://api.github.com/repos/revanced/revanced-$1/releases | grep -m 1 "tag_name")"
	version="${version:18:-2}"

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
