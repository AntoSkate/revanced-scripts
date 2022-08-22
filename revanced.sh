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

# Get ReVanced CLI parameters

parameters=$3

# Get base apk name

base=$4

# Get adb device

adb start-server
adb="$(adb devices | grep '[[:alnum:]]')"
adb="${adb:24:-7}"

# ReVanced CLI base command

revanced="$(java -jar revanced-cli-all.jar -a $base -c -m integrations.apk -b revanced-patches.jar -o $app.apk $parameters )"

# ReVanced root

if [[ "$method" == "root" ]]
then
	$revanced -d $adb -e microg-support -e music-microg-support --mount

# ReVanced install

elif [[ "$method" == "install" ]]
then
	$revanced -d $adb

# ReVanced apk

elif [[ "$method" == "apk" ]]
then
	$revanced

# Error message

else
	echo "Valid installation methods are only root, install or apk."
fi

# Delete files

rm $base
rm revanced-cli-all.jar
rm revanced-patches.jar
rm integrations.apk
