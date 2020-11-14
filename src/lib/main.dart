import 'dart:io';

import 'package:com_4_all/TranscriberPage.dart';
import 'package:flutter/material.dart';
import 'SynthesizerPage.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'db',
    options: FirebaseOptions(
      appId: '1:1288171748:android:6cf94dac89814af44e7cf1',
      apiKey: 'VC3lpiVM9cQb2opJNZKP70uc64iniz4JKiCmuNGo',
      messagingSenderId: '297855924061',
      projectId: 'com4all',
      databaseURL: 'https://com4all-36c11.firebaseio.com/',
    ),
  );

  runApp(App());
}

class App extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          //return SomethingWentWrong();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return LoadingApp();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Com4All'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void goToSynthesizerPage(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SynthesizerPage(title: 'Synthesizer',)),
    );
  }
  void goToTranscriberPage(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TranscriberPage(title: 'Transcriber',)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              disabledTextColor: Colors.white,
              disabledColor: Colors.white,
              color: Colors.blue,
              child: Text("Synthesizer"),
              onPressed: goToSynthesizerPage,
            ),
            SizedBox(
              height: 20,
            ),
            FlatButton(
              color: Colors.blue,
              disabledTextColor: Colors.white,
              disabledColor: Colors.white,
              child: Text("Transcriber"),
              onPressed: goToTranscriberPage,
            ),
          ],
        ),
      ),
    );
  }
}


class LoadingApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadPage(title: 'Com4All'),
    );
  }
}
class LoadPage extends StatefulWidget {
  LoadPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoadPageState createState() => _LoadPageState();
}
class _LoadPageState extends State<LoadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text("Loading")
          ],
        ),
      ),
    );
  }
}
