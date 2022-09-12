#!/bin/bash
# Download CLI

cli="$(curl -s https://api.github.com/repos/revanced/revanced-cli/releases/latest | grep "tag_name")"
cli="${cli:16:-2}"
curl -L -s "https://github.com/revanced/revanced-cli/releases/download/v$cli/revanced-cli-$cli-all.jar" -o "revanced-cli-all.jar"

# Download patches

patches="$(curl -s https://api.github.com/repos/revanced/revanced-patches/releases/latest | grep "tag_name")"
patches="${patches:16:-2}"
curl -L -s "https://github.com/revanced/revanced-patches/releases/download/v$patches/revanced-patches-$patches.jar" -o "revanced-patches.jar"

# Download integrations

integrations="$(curl -s https://api.github.com/repos/revanced/revanced-integrations/releases/latest | grep "tag_name")"
integrations="${integrations:16:-2}"
curl -L -s "https://github.com/revanced/revanced-integrations/releases/download/v$integrations/app-release-unsigned.apk" -o "integrations.apk"

# Get installation method

method=$1

# Get app name

app=$2
app="${app}.apk"

# Get base apk name

base=$3

# Get ReVanced CLI parameters

parameters=$4

# ReVanced mount

if [[ "$method" == "mount" ]]
then
	# Get adb device

	adb start-server
	adb="$(adb devices | grep '[[:graph:]]')"
	adb="${adb:24:-7}"

	# Mount

	java -jar revanced-cli-all.jar -a $base -c -m integrations.apk -b revanced-patches.jar -o $app -d $adb --mount -e microg-support -e music-microg-support $parameters

# ReVanced unmount

if [[ "$method" == "unmount" ]]
then
	# Get adb device

	adb start-server
	adb="$(adb devices | grep '[[:graph:]]')"
	adb="${adb:24:-7}"

	# Mount

	java -jar revanced-cli-all.jar -a $base -d $adb --uninstall

# ReVanced install

elif [[ "$method" == "install" ]]
then
	# Get adb device

	adb start-server
	adb="$(adb devices | grep '[[:graph:]]')"
	adb="${adb:24:-7}"

	# Install

	java -jar revanced-cli-all.jar -a $base -c -m integrations.apk -b revanced-patches.jar -o $app -d $adb $parameters

# ReVanced apk

elif [[ "$method" == "apk" ]]
then
	# Generate apk

	java -jar revanced-cli-all.jar -a $base -c -m integrations.apk -b revanced-patches.jar -o $app $parameters

# Error message

else
	echo "Quando 'mount', 'unmount', 'install' e 'apk' esistono ma tu usi " + $method + " :|"
fi

# Delete files

rm $base
rm revanced-cli-all.jar
rm revanced-patches.jar
rm integrations.apk
