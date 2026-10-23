$ErrorActionPreference = 'Stop'
Write-Host 'Creating the Android project with your installed Flutter SDK...' -ForegroundColor Cyan
flutter create .

Write-Host 'Applying Version 2 Android notification + biometric settings...' -ForegroundColor Cyan
$manifest = Join-Path $PWD 'android/app/src/main/AndroidManifest.xml'
if (Test-Path $manifest) {
  $m = Get-Content $manifest -Raw
  $m = $m -replace '<manifest xmlns:android="http://schemas.android.com/apk/res/android">', '<manifest xmlns:android="http://schemas.android.com/apk/res/android">`r`n    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />`r`n    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />`r`n    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />`r`n    <uses-permission android:name="android.permission.USE_BIOMETRIC" />'
  $receivers = @'
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
'@
  if ($m -notmatch 'ScheduledNotificationReceiver') { $m = $m -replace '</application>', ($receivers + '    </application>') }
  Set-Content $manifest $m
}

$activity = Get-ChildItem -Path 'android/app/src/main' -Recurse -Filter 'MainActivity.kt' | Select-Object -First 1
if ($null -ne $activity) {
  $a = Get-Content $activity.FullName -Raw
  $a = $a -replace 'import io.flutter.embedding.android.FlutterActivity', 'import io.flutter.embedding.android.FlutterFragmentActivity'
  $a = $a -replace 'class MainActivity : FlutterActivity\(\)', 'class MainActivity : FlutterFragmentActivity()'
  Set-Content $activity.FullName $a
}

Write-Host 'Installing Dart packages...' -ForegroundColor Cyan
flutter pub get
Write-Host ''
Write-Host 'Setup complete. Start your Pixel 8 emulator and run: flutter run' -ForegroundColor Green
