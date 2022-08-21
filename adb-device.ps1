# Get adb device

adb start-server
$adb = adb devices | Select-String -Pattern "\w+"
$adb = $adb.Matches.Groups[1].Value
