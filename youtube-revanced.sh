# Download ReVanced
./download-revanced.sh

# Get adb device

adb start-server
adb="$(adb devices | grep '[[:alnum:]]')"
adb="${adb:24:-7}"

# Get base apk name
base=$1

# Install youtube (without root)

java -jar revanced-cli-all.jar -a $base -c -d $adb -o youtube.apk -m integrations.apk -b revanced-patches.jar -e swipe-controls -e seekbar-tapping -e disable-create-button -e hide-autoplay-button -e old-quality-layout -e hide-shorts-button -e force-vp9-codec -e always-autorepeat -e enable-debugging -e hide-infocard-suggestions

# Delete ReVanced files

rm $base
./remove-revanced.sh
