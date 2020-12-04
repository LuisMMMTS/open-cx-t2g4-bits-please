import 'package:com_4_all/Globals.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:com_4_all/SpeakerPage.dart';
import 'package:com_4_all/AttendeePage.dart';

int index = 1;
bool settings = false;
Future<FirebaseApp> _initialization = initiateFuture();

Future<FirebaseApp> initiateFuture() async{
  var init;
  if (Firebase.apps.length == 0) {
    try {
      init = Firebase.initializeApp(
        name: 'db',
        options: FirebaseOptions(
          appId: '1:1288171748:android:6cf94dac89814af44e7cf1',
          apiKey: 'VC3lpiVM9cQb2opJNZKP70uc64iniz4JKiCmuNGo',
          messagingSenderId: '297855924061',
          projectId: 'com4all',
          databaseURL: 'https://com4all-36c11.firebaseio.com/',
        ),
      );
    }
    finally{
      init = Firebase.initializeApp();
    }
  }
  else{
    init = Firebase.initializeApp();
  }
  return init;
}

void main(){
  runApp(AppInitializer());
}

class AppInitializer extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          //return SomethingWentWrong();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return App();
        }

        return LoadingApp();
      },
    );
  }
}

class App extends StatelessWidget {
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
      home: HomePage(title: 'Com4All'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void goToAttendeePage(){
    setState(() {
      index = 2;
      settings = false;
    });
  }
  void goToSpeakerPage(){
    setState(() {
      index = 0;
      settings = false;
    });
  }
  void toggleDarkMode(bool value){
    setState(() {
      darkMode = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Stack(
        children: <Widget>[
          new Offstage(
            offstage: settings == false,
            child: new TickerMode(
                enabled: index == 2,
                child:  Scaffold(
                  appBar: new AppBar(
                    backgroundColor: buttonColor(),
                    title: Text("Settings"),
                    actions: [
                      GestureDetector(
                          child: Icon(Icons.keyboard_return),
                          onTap: (){
                            setState(() {
                              settings = false;
                            });
                          }
                      )
                    ],
                  ),
                  body: Scaffold(
                    backgroundColor: backgroundColor(),
                    body: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Dark Mode",style: buttonTextStyle(),),
                              Switch(
                                value: darkMode,
                                onChanged: toggleDarkMode,
                                activeColor: buttonColor(),
                                activeTrackColor: Colors.grey,
                              )
                            ]
                        )
                    ),
                  ),
                )
            ),
          ),
          new Offstage(
            offstage: (index != 2) || (settings == true),
            child: new TickerMode(
              enabled: index == 2,
              child: new AttendeePage(title: 'Attendee',),
            ),
          ),
          new Offstage(
            offstage: (index != 0) || (settings == true),
            child: new TickerMode(
              enabled: index == 0,
              child: new SpeakerPage(title: 'Speaker',),
            ),
          ),
          new Offstage(
            offstage: (index != 1) || (settings == true),
            child: new TickerMode(
              enabled: index == 1,
              child: Scaffold(
                backgroundColor: backgroundColor(),
                appBar: AppBar(
                  backgroundColor: buttonColor(),
                  title: Text(widget.title),
                  actions: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          settings = true;
                        });
                      },
                      child: Icon(Icons.settings),
                    ),
                  ],
                ),
                body:  Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        key: Key("attendeeBtn"),
                        disabledTextColor: Colors.white,
                        disabledColor: Colors.white,
                        color: buttonColor(),
                        child: Text("Attendee",style:  buttonTextStyle(),),
                        onPressed: goToAttendeePage,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FlatButton(
                        key: Key("speakerBtn"),
                        color: buttonColor(),
                        disabledTextColor: Colors.white,
                        disabledColor: Colors.white,
                        child: Text("Speaker",style:  buttonTextStyle(),),
                        onPressed: goToSpeakerPage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: index,
        onTap: (int i) {
          setState((){
            index = i;
            settings = false;
          });
        },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
            icon: new Icon(Icons.mic),
            label: "Speaker",
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: "Home",
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.speaker_phone),
            label: "Attendee",
          ),
        ],
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
      home: LoadingPage(title: 'Com4All'),
    );
  }
}
class LoadingPage extends StatefulWidget {
  LoadingPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoadingPageState createState() => _LoadingPageState();
}
class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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


