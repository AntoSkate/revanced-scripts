# Download ReVanced
.\download-revanced.ps1

# Get adb device

adb devices
$adb = adb devices | Select-String -Pattern "\w+"
$adb = $adb.Matches.Groups[1].Value

# Get base apk name
$base = $args[0]

# Install twitter

java -jar revanced-cli-all.jar -a $base -c -d $adb -o twitter.apk -m integrations.apk -b revanced-patches.jar

# Delete ReVanced files

Remove-Item -Path $base
.\remove-revanced.ps1
