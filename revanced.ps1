# Remove aliases
Get-Alias | Remove-Alias -Force

# Silent iwr
$ProgressPreference = 'SilentlyContinue'

# Set script arguments
$operation = $args[0]
$apk = $args[1]
$parameters = $args[2]

# Create functions
function mount {
	java -jar revanced-cli-all.jar patch -d "GmsCore support" -i --mount -o out.apk -p revanced-patches.rvp --purge $parameters $apk
}
function unmount {
	java -jar revanced-cli-all.jar utility uninstall -u -p $apk
}
function install {
	java -jar revanced-cli-all.jar patch -i -o out.apk -p revanced-patches.rvp --purge $parameters $apk
}
function apk {
	java -jar revanced-cli-all.jar patch -o out.apk -p revanced-patches.rvp --purge $parameters $apk
}

# Update ReVanced files
if ( -not ( Test-Path -Path .\version.json -PathType Leaf ) ) {
	$versionfile = "{`n`t`"cli`": `"`",`n`t`"patches`": `"`"`n}"
	$versionfile | Out-File .\version.json
}

$cli = "cli", "revanced-cli-all.jar", "revanced-cli-", "-all.jar"
$patches = "patches", "revanced-patches.rvp", "patches-", ".rvp"

foreach ( $repo in $cli, $patches ) {
	$reponame = $repo[0]
	$repofile = $repo[1]

	$versionfile = Get-Content .\version.json | ConvertFrom-Json
	$oldversion = $versionfile.$reponame

	$version = Invoke-WebRequest -Uri "https://api.revanced.app/v2/revanced-$reponame/releases/latest?dev=true"
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
