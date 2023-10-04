# Mopinion Native SDK for Flutter 

This Flutter Integration SDK contains code to help you use our Android and/or iOS Native/Web SDKs from Flutter.
Tested with Flutter 3.13.4, Dart 3.1.2, DevTools 2.25.0, Xcode 15.0.

## Installation
1. Edit the `pubspec.yml` in your `flutter` directory to define the Mopinion Plugin Dependency:

```
dependencies:

  ...

  mopinion_flutter_integration_plugin: ^${latestVersion}
```

2. Run the following command to get the package:

```
    flutter pub get
```

## Setting up

Now you can import the Mopinion SDK

```dart
    import 'package: mopinion_flutter_integration_plugin/mopinion_flutter_integration_plugin.dart'
```

### Android

   1. Make sure that your MainActivity extends FlutterFragmentActivity
   2. Make sure the min sdk is 21 in your app's `build.gradle`:
   ```
     defaultConfig {
        minSdkVersion 21
    }
   ```

   3. Make sure the app theme extends from a MaterialComponent theme. Please check the [Android Native SDK readme](https://github.com/Mopinion-com/mopinion-sdk-android), step 4 for more info. 