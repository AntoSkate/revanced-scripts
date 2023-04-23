# Remove aliases
Get-Alias | Remove-Alias -Force

# Silent iwr
$ProgressPreference = 'SilentlyContinue'

# Set script arguments
$operation = $args[0]
$apk = $args[1]
$parameters = $args[2]

# Create functions
function get_adb_device {
	adb start-server
	$adb = adb devices | Select-String -Pattern "\S+"
	$script:adb = $adb.Matches.Groups[1].Value
}
function mount {
	get_adb_device
	java -jar revanced-cli-all.jar -a $apk -c -m revanced-integrations.apk -b revanced-patches.jar -o out -d $adb --mount -e vanced-microg-support -e music-microg-support $parameters
}
function unmount {
	get_adb_device
	java -jar revanced-cli-all.jar -a $apk -d $adb --uninstall
}
function install {
	get_adb_device
	java -jar revanced-cli-all.jar -a $apk -c -m revanced-integrations.apk -b revanced-patches.jar -o out -d $adb $parameters
}
function apk {
	java -jar revanced-cli-all.jar -a $apk -c -m revanced-integrations.apk -b revanced-patches.jar -o out $parameters
}

# Update ReVanced files
if ( -not ( Test-Path -Path .\version.json -PathType Leaf ) ) {
	$versionfile = "{`n`t`"cli`": `"`",`n`t`"patches`": `"`",`n`t`"integrations`": `"`"`n}"
	$versionfile | Out-File .\version.json
}

$cli = "cli", "revanced-cli-all.jar", "revanced-cli-", "-all.jar"
$patches = "patches", "revanced-patches.jar", "revanced-patches-", ".jar"
$integrations = "integrations", "revanced-integrations.apk", "revanced-integrations-", ".apk"

foreach ( $repo in $cli, $patches, $integrations ) {
	$reponame = $repo[0]
	$repofile = $repo[1]

	$versionfile = Get-Content .\version.json | ConvertFrom-Json
	$oldversion = $versionfile.$reponame

	$version = Invoke-WebRequest -Uri "https://api.github.com/repos/revanced/revanced-$reponame/releases"
	$version = (( $version | ConvertFrom-Json ).tag_name | Select-Object -First 1).Remove(0,1)

	if ( $oldversion -ne $version ) {
		$repoasset = $repo[2] + $version + $repo[3]

		if ( Test-Path -Path $repofile -PathType Leaf ) {
			Remove-Item -Path $repofile
		}

		$versionfile.$reponame = $version
		$versionfile | ConvertTo-Json | Out-File .\version.json

		Write-Output "---> Downloading $reponame version $version <---"
		Invoke-WebRequest "https://github.com/revanced/revanced-$reponame/releases/download/v$version/$repoasset" -OutFile $repofile
	}
}

# Patch apk
foreach ( $valid_operation in "mount", "unmount", "install", "apk") {
	if ( $operation -eq $valid_operation ) {
		Invoke-Expression $operation
		break
	}
}
