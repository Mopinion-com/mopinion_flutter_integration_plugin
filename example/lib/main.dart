import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mopinion_flutter_integration_plugin/mopinion_flutter_integration_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _state = MopinionFormState.hasNotBeenShown;
  late final StreamSubscription<MopinionFormState> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      MopinionFlutterIntegrationPlugin.initSdk("YOUR_DEPLOYMENT_KEY",
          enableLogging: true);
      _streamSubscription = MopinionFlutterIntegrationPlugin.eventsData()
          .listen(_setFormStateText);
    } catch (error) {
      log(error.toString());
    }
  }

  Future<void> _launchEvent(String eventName) async {
    try {
      await MopinionFlutterIntegrationPlugin.event(eventName);
    } catch (error) {
      log(error.toString());
    }
  }

  void _setFormStateText(MopinionFormState state) {
    setState(() => _state = state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example app Mopinion Flutter Integration Plugin"),
      ),
      body: Center(
        child: Text(
          _state.toString(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _launchEvent("EVENT_NAME"),
        tooltip: 'Launch form',
        child: const Icon(Icons.rocket_launch),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
