# Driver App Setup

## 1. Google Maps API Key
1. Enable **Maps SDK for Android** and **Maps SDK for iOS** in Google Cloud Console.
2. Replace `YOUR_API_KEY` in `lib/core/config/app_config.dart`.

## 2. Android Permissions (`android/app/src/main/AndroidManifest.xml`)
Add inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

Add inside `<application>`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY" />
```

## 3. iOS Permissions (`ios/Runner/Info.plist`)
Add:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show customers where their order is.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to track deliveries even when the app is backgrounded.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to track deliveries even when the app is backgrounded.</string>
```

## 4. Firebase (Optional for MVP)
Run `flutterfire configure` when ready to enable push notifications.

---

## ✅ Next Steps

1.  **Run `flutter pub get`** to install dependencies.
2.  **Update `lib/core/config/app_config.dart`** with your actual API URL.
3.  **Create Missing UI Files:** `HomeScreen`, `ActiveDeliveryScreen`, `LoginScreen` (stubs exist in `app.dart` imports).
4.  **Test Build:** Run `flutter run` to verify compilation (Maps will show placeholder until key is added).