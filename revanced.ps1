# Download CLI

$cli = Invoke-WebRequest -Uri "https://api.github.com/repos/revanced/revanced-cli/releases/latest" | Select-String -Pattern "\d+\u002E\d+\u002E\d+"
$cli = $cli.Matches.Groups[0].Value
Invoke-WebRequest "https://github.com/revanced/revanced-cli/releases/download/v$cli/revanced-cli-$cli-all.jar" -OutFile "revanced-cli-all.jar"

# Download patches

$patches = Invoke-WebRequest -Uri "https://api.github.com/repos/revanced/revanced-patches/releases/latest" | Select-String -Pattern "\d+\u002E\d+\u002E\d+"
$patches = $patches.Matches.Groups[0].Value
Invoke-WebRequest "https://github.com/revanced/revanced-patches/releases/download/v$patches/revanced-patches-$patches.jar" -OutFile "revanced-patches.jar"

# Download integrations

$integrations = Invoke-WebRequest -Uri "https://api.github.com/repos/revanced/revanced-integrations/releases/latest" | Select-String -Pattern "\d+\u002E\d+\u002E\d+"
$integrations = $integrations.Matches.Groups[0].Value
Invoke-WebRequest "https://github.com/revanced/revanced-integrations/releases/download/v$integrations/app-release-unsigned.apk" -OutFile "integrations.apk"

# Get installation method

$method = $args[0]

# Get app name

$app = $args[1]
$app = $app + ".apk"

# Get base apk name

$base = $args[2]

# Get ReVanced CLI parameters

$parameters = $args[3]

# ReVanced mount

if ( $method -eq "mount" )
{
	# Get adb device

	adb start-server
	$adb = adb devices | Select-String -Pattern "\w+"
	$adb = $adb.Matches.Groups[1].Value

	# Mount

	java -jar revanced-cli-all.jar -a $base -c -m integrations.apk -b revanced-patches.jar -o $app -d $adb --mount -e microg-support -e music-microg-support $parameters
}

# ReVanced install

elseif ( $method -eq "install" )
{
	# Get adb device

	adb start-server
	$adb = adb devices | Select-String -Pattern "\w+"
	$adb = $adb.Matches.Groups[1].Value

	# Install

	java -jar revanced-cli-all.jar -a $base -c -m integrations.apk -b revanced-patches.jar -o $app -d $adb $parameters
}

# ReVanced apk

elseif ( $method -eq "apk" )
{
	# Generate apk

	java -jar revanced-cli-all.jar -a $base -c -m integrations.apk -b revanced-patches.jar -o $app $parameters

}

# Error message

else
{
	Write-Output "Valid installation methods are only mount, install or apk."
}

# Delete files

Remove-Item -Path $base
Remove-Item -Path revanced-cli-all.jar
Remove-Item -Path revanced-patches.jar
Remove-Item -Path integrations.apk
