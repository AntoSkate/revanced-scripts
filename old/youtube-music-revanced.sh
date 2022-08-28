# Download ReVanced
./download-revanced.sh

# Get adb device

adb start-server
adb="$(adb devices | grep '[[:alnum:]]')"
adb="${adb:24:-7}"

# Get base apk name
base=$1

# Install youtube music (without root)

java -jar revanced-cli-all.jar -a $base -c -d $adb -o youtube.apk -m integrations.apk -b revanced-patches.jar -e compact-header

# Delete ReVanced files

rm $base
./remove-revanced.sh
