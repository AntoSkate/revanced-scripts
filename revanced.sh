#!/bin/bash

echo -e "//TODO\nuse $(dirname 0) to return the script location when using it from another directory\n\n"

# Set script arguments
operation=$1
apk=$2
parameters=$3

# Create functions
mount() {
	java -jar revanced-cli-all.jar patch -d "GmsCore support" -i --mount -o out.apk -p revanced-patches.rvp --purge $parameters $apk
}
unmount() {
	java -jar revanced-cli-all.jar utility uninstall -u -p $apk
}
install() {
	java -jar revanced-cli-all.jar patch -i -o out.apk -p revanced-patches.rvp --purge $parameters $apk
}
apk() {
	java -jar revanced-cli-all.jar patch -o out.apk -p revanced-patches.rvp --purge $parameters $apk
}

# Update ReVanced files
if [[ ! -f version.json ]]
then
	echo -e '{\n\t"cli": "",\n\t"patches": ""\n}' > version.json
fi

for repo in "cli 9 -2 revanced-cli-all.jar revanced-cli- -all.jar" "patches 13 -1 revanced-patches.rvp patches- .rvp"
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

$(echo -e "{\n\t\"cli\": \"$cli\",\n\t\"patches\": \"$patches\"\n}" > version.json)

# Patch apk
for valid_operation in mount unmount install apk
do
	if [[ "$operation" == "$valid_operation" ]]
	then
		$operation
		break
	fi
done
