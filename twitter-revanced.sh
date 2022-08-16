# Download ReVanced
./download-revanced.sh

# Get adb device

adb start-server
adb="$(adb devices | grep '[[:alnum:]]')"
adb="${adb:24:-7}"

# Get base apk name
base=$1

# Install twitter

java -jar revanced-cli-all.jar -a $base -c -d $adb -o twitter.apk -m integrations.apk -b revanced-patches.jar

# Delete ReVanced files

rm $base
./remove-revanced.sh
