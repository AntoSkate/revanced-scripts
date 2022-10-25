# Silent iwr

$ProgressPreference = 'SilentlyContinue'

# Update ReVanced files

if ( -not ( Test-Path -Path .\version.json -PathType Leaf ) ) {
$version = @"
{
	"cli": "",
	"patches": "",
	"integrations": ""
}
"@

$version | Out-File .\version.json
}

$version = Get-Content .\version.json | ConvertFrom-Json

$cli = Invoke-WebRequest -Uri "https://api.github.com/repos/revanced/revanced-cli/releases/latest"
$cli = ( $cli | ConvertFrom-Json  ).tag_name -replace 'v',''
$patches = Invoke-WebRequest -Uri "https://api.github.com/repos/revanced/revanced-patches/releases/latest"
$patches = ( $patches | ConvertFrom-Json).tag_name -replace 'v',''
$integrations = Invoke-WebRequest -Uri "https://api.github.com/repos/revanced/revanced-integrations/releases/latest"
$integrations = ( $integrations | ConvertFrom-Json ).tag_name -replace 'v',''

if ( $version.cli -lt $cli ) {
	if ( Test-Path -Path .\revanced-cli-all.jar -PathType Leaf ) {
		Remove-Item -Path .\revanced-cli-all.jar
	}
	
	$version.cli = $cli
	$version | ConvertTo-Json | Out-File .\version.json

	Invoke-WebRequest "https://github.com/revanced/revanced-cli/releases/download/v$cli/revanced-cli-$cli-all.jar" -OutFile "revanced-cli-all.jar"
}

if ( $version.patches -lt $patches ) {
	if ( Test-Path -Path .\revanced-patches.jar -PathType Leaf ) {
		Remove-Item -Path .\revanced-patches.jar
	}
	
	$version.patches = $patches
	$version | ConvertTo-Json | Out-File .\version.json

	Invoke-WebRequest "https://github.com/revanced/revanced-patches/releases/download/v$patches/revanced-patches-$patches.jar" -OutFile "revanced-patches.jar"
}

if ( $version.integrations -lt $integrations ) {
	if ( Test-Path -Path .\integrations.apk -PathType Leaf ) {
		Remove-Item -Path .\integrations.apk
	}
	
	$version.integrations = $integrations
	$version | ConvertTo-Json | Out-File .\version.json

	Invoke-WebRequest "https://github.com/revanced/revanced-integrations/releases/download/v$integrations/app-release-unsigned.apk" -OutFile "integrations.apk"
}

# Get installation method

$method = $args[0]

# Get apk name

$apk = $args[1]

# Get ReVanced CLI parameters

$parameters = $args[2]

# Revanced CLI command

$revanced = "java -jar .\revanced-cli-all.jar -a " + $apk + " -c -o out -b .\revanced-patches.jar -m .\integrations.apk " + $parameters

# ReVanced mount

if ( $method -eq "mount" )
{
	# Get adb device

	adb start-server
	$adb = adb devices | Select-String -Pattern "\S+"
	$adb = $adb.Matches.Groups[1].Value

	# Mount

	$revanced = $revanced + " -e microg-support -e music-microg-support -d " + $adb + " --mount"
	Invoke-Expression -Command $revanced
}

# ReVanced unmount

elseif ( $method -eq "unmount" )
{
	# Get adb device

	adb start-server
	$adb = adb devices | Select-String -Pattern "\S+"
	$adb = $adb.Matches.Groups[1].Value

	# Unmount

	$revanced = "java -jar .\revanced-cli-all.jar -a " + $apk + " -d " + $adb + " --uninstall"
	Invoke-Expression -Command $revanced
}

# ReVanced install

elseif ( $method -eq "install" )
{
	# Get adb device

	adb start-server
	$adb = adb devices | Select-String -Pattern "\S+"
	$adb = $adb.Matches.Groups[1].Value

	# Install

	$revanced = $revanced + " -d " + $adb
	Invoke-Expression -Command $revanced
}

# ReVanced apk

elseif ( $method -eq "apk" )
{
	# Generate apk

	Invoke-Expression -Command $revanced
}
