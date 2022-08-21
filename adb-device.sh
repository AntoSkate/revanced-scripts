# Get adb device

adb start-server
adb="$(adb devices | grep '[[:alnum:]]')"
adb="${adb:24:-7}"
