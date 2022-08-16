# Download ReVanced
.\download-revanced.ps1

# Get adb device

adb start-server
$adb = adb devices | Select-String -Pattern "\w+"
$adb = $adb.Matches.Groups[1].Value

# Get base apk name
$base = $args[0]

# Install youtube music (without root)

java -jar revanced-cli-all.jar -a $base -c -d $adb -o youtube.apk -m integrations.apk -b revanced-patches.jar -e compact-header

# Delete ReVanced files

Remove-Item -Path $base
.\remove-revanced.ps1
