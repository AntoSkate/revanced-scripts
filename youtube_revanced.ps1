# Download ReVanced
.\download_revanced.ps1

# Get adb device

adb devices
$adb = adb devices | Select-String -Pattern "\w+"
$adb_device = $adb.Matches.Groups[1].Value

# Get base apk name
$base_apk = $args[0]

# Install youtube (without root)

java -jar revanced-cli-all.jar -a $base_apk -c -d $adb_device -o youtube.apk -m integrations.apk -b revanced-patches.jar -e swipe-controls -e seekbar-tapping -e disable-create-button -e hide-autoplay-button -e old-quality-layout -e hide-shorts-button -e force-vp9-codec -e always-autorepeat -e enable-debugging -e hide-infocard-suggestions

# Delete ReVanced files

.\remove_revanced.ps1
