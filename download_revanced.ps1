# Download CLI

$cli = Invoke-WebRequest -Uri "https://api.github.com/repos/revanced/revanced-cli/releases/latest" | Select-String -Pattern "\d+\u002E\d+\u002E\d+"
$cliVersion = $cli.Matches.Groups[0].Value
Invoke-WebRequest "https://github.com/revanced/revanced-cli/releases/download/v$cliVersion/revanced-cli-$cliVersion-all.jar" -OutFile "revanced-cli-all.jar"

# Download patches

$patches = Invoke-WebRequest -Uri "https://api.github.com/repos/revanced/revanced-patches/releases/latest" | Select-String -Pattern "\d+\u002E\d+\u002E\d+"
$patchesVersion = $patches.Matches.Groups[0].Value
Invoke-WebRequest "https://github.com/revanced/revanced-patches/releases/download/v$patchesVersion/revanced-patches-$patchesVersion.jar" -OutFile "revanced-patches.jar"

# Download integrations

$integrations = Invoke-WebRequest -Uri "https://api.github.com/repos/revanced/revanced-integrations/releases/latest" | Select-String -Pattern "\d+\u002E\d+\u002E\d+"
$integrationsVersion = $integrations.Matches.Groups[0].Value
Invoke-WebRequest "https://github.com/revanced/revanced-integrations/releases/download/v$integrationsVersion/app-release-unsigned.apk" -OutFile "integrations.apk"

# Clear

Clear-Host

# Build patches
#git clone https://github.com/revanced/revanced-patcher && Set-Location revanced-patcher
#./gradlew build
#Set-Location ..
#git clone https://github.com/revanced/revanced-patches && Set-Location revanced-patches
#Remove-Item -Path .\src\main\resources\branding -Recurse
#Copy-Item -Path ..\logo\branding -Destination .\src\main\resources\ -Recurse
#./gradlew build
#Move-Item -Path .\build\libs\revanced-patches-*.*.*.jar -Destination ..\revanced-patches.jar
#Set-Location ..
