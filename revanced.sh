#!/bin/bash
# Update ReVanced files

if [[ ! -f version.json ]]
then
	echo -e '{\n\t"cli": "",\n\t"patches": "",\n\t"integrations": ""\n}' > version.json
fi

cliversion="$(grep "cli" version.json)"
cliversion="${cliversion:9:-2}"
patchesversion="$(grep "patches" version.json)"
patchesversion="${patchesversion:13:-2}"
integrationsversion="$(grep "integrations" version.json)"
integrationsversion="${integrationsversion:18:-1}"

cli="$(curl -s https://api.github.com/repos/revanced/revanced-cli/releases | grep -m 1 "tag_name")"
cli="${cli:18:-2}"
patches="$(curl -s https://api.github.com/repos/revanced/revanced-patches/releases | grep -m 1 "tag_name")"
patches="${patches:18:-2}"
integrations="$(curl -s https://api.github.com/repos/revanced/revanced-integrations/releases | grep -m 1 "tag_name")"
integrations="${integrations:18:-2}"

if [[ $cliversion != $cli ]]
then
	if [[ -f revanced-cli-all.jar ]]
	then
		rm revanced-cli-all.jar
	fi

	cliversion=$cli

	curl -L -s "https://github.com/revanced/revanced-cli/releases/download/v$cli/revanced-cli-$cli-all.jar" -o "revanced-cli-all.jar"
fi

if [[ $patchesversion != $patches ]]
then
	if [[ -f revanced-patches.jar ]]
	then
		rm revanced-patches.jar
	fi

	patchesversion=$patches

	curl -L -s "https://github.com/revanced/revanced-patches/releases/download/v$patches/revanced-patches-$patches.jar" -o "revanced-patches.jar"
fi

if [[ $integrationsversion != $integrations ]]
then
	if [[ -f integrations.apk ]]
	then
		rm integrations.apk
	fi

	integrationsversion=$integrations

	curl -L -s "https://github.com/revanced/revanced-integrations/releases/download/v$integrations/app-release-unsigned.apk" -o "integrations.apk"
fi

$(echo -e "{\n\t\"cli\": \"$cliversion\",\n\t\"patches\": \"$patchesversion\",\n\t\"integrations\": \"$integrationsversion\"\n}" > version.json)

# Get installation method

method=$1

# Get apk name

apk=$2

# Get ReVanced CLI parameters

parameters=$3

# ReVanced mount

if [[ "$method" == "mount" ]]
then
	
	# Get adb device

	adb start-server
	adb="$(adb devices | grep '[[:graph:]]')"
	adb="${adb:24:-7}"

	# Mount

	java -jar revanced-cli-all.jar -a $apk -c -m integrations.apk -b revanced-patches.jar -o out -d $adb --mount -e microg-support -e music-microg-support $parameters

# ReVanced unmount

elif [[ "$method" == "unmount" ]]
then
	# Get adb device

	adb start-server
	adb="$(adb devices | grep '[[:graph:]]')"
	adb="${adb:24:-7}"

	# Mount

	java -jar revanced-cli-all.jar -a $apk -d $adb --uninstall

# ReVanced install

elif [[ "$method" == "install" ]]
then
	# Get adb device

	adb start-server
	adb="$(adb devices | grep '[[:graph:]]')"
	adb="${adb:24:-7}"

	# Install

	java -jar revanced-cli-all.jar -a $apk -c -m integrations.apk -b revanced-patches.jar -o out -d $adb $parameters

# ReVanced apk

elif [[ "$method" == "apk" ]]
then
	# Generate apk

	java -jar revanced-cli-all.jar -a $apk -c -m integrations.apk -b revanced-patches.jar -o out $parameters

fi
