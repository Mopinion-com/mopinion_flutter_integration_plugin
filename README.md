# Mopinion Native SDK for Flutter 

This Flutter Integration SDK contains code to help you use our Android and/or iOS Native/Web SDKs from Flutter.


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

   1. Make sure that your MainActivity extends FlutterFragmentActivity
   2. Make sure the min sdk is 21 in your app's `build.gradle`:
   ```
     defaultConfig {
        minSdkVersion 21
    }
   ```

   3. Make sure the app theme extends from a MaterialComponent theme. Please check the [Android Native SDK readme](https://github.com/Mopinion-com/mopinion-sdk-android), step 4 for more info. 

### iOS
Install the Mopinion SDK for iOS to make it an available resource for the Flutter plugin.

1. Open your iOS project Runner.xcodeproj with Xcode.
2. Set the iOS Deployment Target to 9.0 or above.
3. Uncomment or add platform :ios, '9.0' to the podfile.
   ```
   # Uncomment this line to define a global platform for your project
    platform :ios, '9.0'
   ```
The run the Flutter App. Incase of a failure regarding Pods than fetching the the latest Mopinion SDK for iOS, it can be solved by updating the Pod. This can be achieved running the following command:

```pod --repo-update install```

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
MopinionFlutterIntegrationPlugin.initSdk("YOUR_KEY", log: true);
```
The parameter `log` allows to activate the logging in the SDK.
It's recommended to initialise the SDK the earliest possible, an example of where to initialise the SDK:

```dart
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    try {
       MopinionFlutterIntegrationPlugin.initSdk(YOUR_KEY, true);
    } on PlatformException {
      print("error");
    } 
  }
```

### Calling events
In order to show your forms, call the function :
```dart
MopinionFlutterIntegrationPlugin.event(EVENT_NAME);
```

The `MopinionFlutterIntegrationPlugin.event(EVENT_NAME)` function will also stream an Form State to show in which state the form is. To be able to listen to that callback you can call the function `MopinionFlutterIntegrationPlugin.eventsData()` which returns an `Stream`. Example of usage:

```dart
    Stream stream;
    try {
      stream = await MopinionFlutterIntegrationPlugin.eventsData();
      stream.listen(_setTextEventName, onError: _onError);
    } on PlatformException {
      print("Failed to get events stream.");
    }

    void _setTextEventName(event) {
    setState(() => _yourState_ = event);
  }
```

The Form State callback will be a `String`, and these are the possible Form States:

* Loading
* FormOpened
* FormSent
* FormCanceled
* FormClosed
* Error
* HasNotBeenShown

More information about the Form States can be found in each readme of the Native SDKs:

[iOS: 2.4.2 Callback variants of the event method](https://github.com/Mopinion-com/mopinion-sdk-ios#242-callback-variants-of-the-event-method)
[Android: Implementing Form State callbacks](https://github.com/Mopinion-com/mopinion-sdk-android#implementing-formstate-callbacks)

### Adding Metadata

Adding Metadata in the Mopinion SDK is easy, it's achieved by calling the function

```dart
  MopinionFlutterIntegrationPlugin.data(Map);
```

This function will receive a `Map<String, String>` variable which will contain the metadata you want to set in your events. Example of usage:

```dart
  Map<String, String> map = {
        "age": "29",
        "name": "Manuel"
      };
  MopinionFlutterIntegrationPlugin.data(map);
  MopinionFlutterIntegrationPlugin.event(yourEvent);
```

#### Deleting Metadata by key
When a key data from the Metadata `Map<String, String>` provided to the SDK wants to be deleted then we should just pass the `key` value as the following:

```dart
  MopinionFlutterIntegrationPlugin.removeMetaData("name");
```

This will remove the key `name` from the Metadata `Map` provided.

#### Deleting all Metadata
When all Metadata wants to be deleted, it's even simplier, just call 

```dart
MopinionFlutterIntegrationPlugin.removeAllMetaData();
```
And all Metadata will be deleted.


