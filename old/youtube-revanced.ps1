# Download ReVanced
.\download-revanced.ps1

# Get adb device

.\adb-device.ps1

# Get base apk name
$base = $args[0]

# Install youtube (without root)

java -jar revanced-cli-all.jar -a $base -c -d $adb -o youtube.apk -m integrations.apk -b revanced-patches.jar -e swipe-controls -e seekbar-tapping -e disable-create-button -e hide-autoplay-button -e old-quality-layout -e hide-shorts-button -e force-vp9-codec -e always-autorepeat -e enable-debugging -e hide-infocard-suggestions

# Delete ReVanced files

Remove-Item -Path $base
.\remove-revanced.ps1
