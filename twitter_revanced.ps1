# Download ReVanced
.\download_revanced.ps1

# Get adb device

adb devices
$adb = adb devices | Select-String -Pattern "\w+"
$adb_device = $adb.Matches.Groups[1].Value

# Install twitter

java -jar revanced-cli-all.jar -a base.apk -c -d $adb_device -o twitter.apk -m integrations.apk -b revanced-patches.jar

# Delete ReVanced files

.\remove_revanced.ps1
