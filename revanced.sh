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

# Get installation/generation type

type=$1

# Get app name

app=$2

# Get base apk name

base=$3

# Get ReVanced cli parameters

parameters=$4

# Get adb device

adb start-server
adb="$(adb devices | grep '[[:alnum:]]')"
adb="${adb:24:-7}"

# ReVanced CLI base command

revanced="$(java -jar revanced-cli-all.jar -a $base -c -m integrations.apk -b revanced-patches.jar -o $app.apk $parameters )"

# ReVanced

if [[ $type -eq "root" ]]
	$revanced -d $adb -e microg-support --mount
else
	if [[ $type -eq "install" ]]
		$revanced -d $adb
	else
		if [[ $type -eq "apk" ]]
			$revanced
		else
			echo "Valid types are only root, install or apk."
		fi
	fi
fi

# Delete files

rm $base
rm revanced-cli-all.jar
rm revanced-patches.jar
rm integrations.apk
