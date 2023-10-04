import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';


import 'package:mopinion_flutter_integration_plugin/mopinion_flutter_integration_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _state = "no state";


  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    try {
       MopinionFlutterIntegrationPlugin.initSdk("zdF2CDO4NZ523sDqdzDDgzKaMb7zbsdzIuQPxUBk", true);
       events();
    } on PlatformException {
      print("error");
    } 
  }

  Future<void> _launchEvent(String eventName) async {
    setState(() {
      
      MopinionFlutterIntegrationPlugin.event(eventName);
    });
  }

  void _setTextEventName(event) {
    setState(() => _state = event);
  }

  Future<void> events() async {
    Stream stream;
    try {
      stream = await MopinionFlutterIntegrationPlugin.eventsData();
      stream.listen(_setTextEventName, onError: _onError);
    } on PlatformException {
      print("Failed to get events stream.");
    }
  }

  static void _onError(error) {
    print("Error info: $error");
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Counter',
            ),
            Text(
              _state,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _launchEvent("bug1");
          
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
