# Mopinion Native SDK for Flutter

Use the Mopinion Flutter Plugin to integrate our native iOS and Android SDKs in your Flutter applications.

## Native SDKs readme's

- [Android Native SDK](https://github.com/Mopinion-com/mopinion-sdk-android)
- [iOS Native SDK](https://github.com/Mopinion-com/mopinion-sdk-ios-swiftpm)

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

## Native set up

### Android

1.  Open the Android project with Android Studio.
2.  Make sure that your `MainActivity.kt` extends `FlutterFragmentActivity`.

    ```kotlin
    import io.flutter.embedding.android.FlutterFragmentActivity

    class MainActivity: FlutterFragmentActivity() {
      // Your code...
    }
    ```

3.  Make sure the min sdk is 21 in your `app` `build.gradle`:

```groovy
  defaultConfig {
     minSdkVersion 21
 }
```

4. In your `Project` `build.gradle` include the Jitpack repository:
   ```groovy
   maven {
     url 'https://www.jitpack.io'
   }
   ```
1. Sync gradle.
1. Make sure the app theme extends from a MaterialComponent theme. Please check the [Android Native SDK readme step 4](https://github.com/Mopinion-com/mopinion-sdk-android#step-4) for more info.

### iOS

Install the Mopinion SDK for iOS to make it an available resource for the Flutter plugin.

1. Open in the terminal the `ios` folder and run `pod install` command.
2. Set the iOS Deployment Target to 11.0 or above.

## Flutter implementation

In order to use Mopinion SDK for Flutter and start collecting your valuable user's feedback please follow the following steps:

### Import the plugin

Import the plugin class

```dart
import 'package:mopinion_flutter_integration_plugin/mopinion_flutter_integration_plugin.dart';
```

### Initialise the SDK

Initialise the SDK by calling:

```dart
MopinionFlutterIntegrationPlugin.initSdk("YOUR_DEPLOYMENT_ID", enableLogging: true);
```

The parameter `log` which is the `boolean` after the key, allows to activate the logging in the SDK.
It's recommended to initialise the SDK the earliest possible, an example of where to initialise the SDK:

```dart
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    try {
      await MopinionFlutterIntegrationPlugin.initSdk("YOUR_DEPLOYMENT_ID", true);
    } catch (error) {
      print(error.toString());
    }
  }
```

### Calling events

In order to show your forms, call the function :

```dart
MopinionFlutterIntegrationPlugin.event("EVENT_NAME");
```

The `MopinionFlutterIntegrationPlugin.event("EVENT_NAME")` function will also stream an Form State to show in which state the form is. To be able to listen to that callback you can call the function `MopinionFlutterIntegrationPlugin.eventsData()` which returns an `Stream`. Example of usage:

```dart
    MopinionFlutterIntegrationPlugin.eventsData().listen(_setFormStateStatus)


    void _setFormStateStatus(MopinionFormState state) {
      setState(() => _state = state);
    }
```

The Form State callback will be an enum called `MopinionFormState`, and these are the possible Form States:

- Loading ¹
- NotLoading ¹
- FormOpened
- FormSent
- FormCanceled
- FormClosed
- Error
- HasNotBeenShown

More information about the Form States can be found in each readme of the Native SDKs:

[iOS: 2.4.2 Callback variants of the event method](https://github.com/Mopinion-com/mopinion-sdk-ios#242-callback-variants-of-the-event-method)
[Android: Implementing Form State callbacks](https://github.com/Mopinion-com/mopinion-sdk-android#implementing-formstate-callbacks)

¹ These form states are only available in the Android SDK by the moment.

### Adding Metadata

Adding Metadata in the Mopinion SDK is easy, it's achieved by calling the function

```dart
  await MopinionFlutterIntegrationPlugin.data(map);
```

This function will receive a `Map<String, String>` variable which will contain the metadata you want to set in your events. Example of usage:

```dart
  Map<String, String> map = {
        "age": "29",
        "name": "Manuel"
      };
  await MopinionFlutterIntegrationPlugin.data(map);
  await MopinionFlutterIntegrationPlugin.event(yourEvent);
```

#### Deleting Metadata by key

When a key data from the Metadata `Map<String, String>` provided to the SDK wants to be deleted then we should just pass the `key` value as the following:

```dart
MopinionFlutterIntegrationPlugin.removeMetaData("name");
```

This will remove the key `name` from the Metadata `Map` provided.

#### Deleting all Metadata

When all Metadata wants to be deleted, it's even simpler, just call

```dart
MopinionFlutterIntegrationPlugin.removeAllMetaData();
```

And all Metadata will be deleted.
