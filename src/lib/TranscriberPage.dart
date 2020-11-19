import 'dart:async';

import 'package:com_4_all/TranscriberResult.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

import 'package:com_4_all/database/Database.dart';

import 'Messaging/MessagingFirebase.dart';
import 'Transcriber.dart';
import 'TranscriberSpeechToText.dart';

import 'Messaging/Messaging.dart';
import 'database/DatabaseFirebase.dart';

int index = 0;

class TranscriberPage extends StatefulWidget {
  final String title;
  TranscriberPage({Key key, this.title}) : super(key: key);
  @override
  _TranscriberPageState createState() => _TranscriberPageState();
}

class _TranscriberPageState extends State<TranscriberPage> {
  bool _hasSpeech = false;
  Transcriber transcriber;

  TextFormField sessionIDForm;
  var sessionIDController = new TextEditingController();
  String sessionID = "";
  String speakerToken = "";
  List<String> receivedMessages = new List<String>();
  ScrollController scrollController =
      new ScrollController(initialScrollOffset: 50.0);

  Messaging messaging;

  Database database = new DatabaseFirebase();

  Future<void> initializeTranscriber() async {
    transcriber = TranscriberSpeechToText();
    transcriber.initialize(
      onBegin: beginListener,
      onResult: resultListener,
      onSoundLevel: soundLevelListener,
      onEnd: endListener,
      onError: errorListener
    );
    bool hasSpeech = await transcriber.initSpeech();
    if (hasSpeech) {
      print("Initialized voice recognition\n");
      _localeNames = await transcriber.getLocales();

      var systemLocale = await transcriber.getSystemLocale();
      _currentLocaleId = systemLocale.localeId;
    } else {
      print("Failed to initialize voice recognition\n");
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  double level = 0.0;
  String allWords = "";
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];

  @override
  void initState() {
    super.initState();
    initializeTranscriber();
    setupMessaging();

    sessionIDForm = TextFormField(
      controller: sessionIDController,
      decoration: InputDecoration(
        labelText: "Enter the session ID",
      ),
      expands: false,
      maxLines: 1,
      minLines: 1,
    );
  }

  void getMessage(dynamic r) {
    print(r.toString());
    receivedMessages.add(r.toString());
    setState(() {});
    scrollController.animateTo(
        scrollController.position.maxScrollExtent.ceilToDouble() +
            receivedMessages.last.length,
        duration: Duration(milliseconds: 500),
        curve: Curves.bounceIn);
  }

  Future setupMessaging() async {
    messaging = new MessagingFirebase(getMessage);
    speakerToken = await messaging.getToken();
  }

  Future checkSession() async {
    sessionID = sessionIDController.text;
    if (sessionID != "") {
      index = 1;
      database.addToken(sessionID, speakerToken);
    } else {
      sessionIDForm = TextFormField(
        controller: sessionIDController,
        decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: "Enter the session ID",
            errorText: "Not a valid session ID"),
        expands: false,
        maxLines: 1,
        minLines: 1,
      );
      sessionIDController.clear();
    }
    setState(() {});
  }

  Container getMicrophoneButton() {
    return Container(
      width: 40,
      decoration: ShapeDecoration(
        shadows: [
          BoxShadow(
            blurRadius: .1,
            spreadRadius: (transcriber.isListening ? level : 0) * 1.0,
            color: Colors.red.withOpacity(.50),
          ),
        ],
        color: (!_hasSpeech
            ? Colors.grey
            : (!transcriber.isListening ? Colors.white : Colors.red)),
        shape: CircleBorder(),
      ),
      child: IconButton(
        icon: Icon(Icons.mic),
        color: (!_hasSpeech
            ? Colors.grey
            : (!transcriber.isListening ? Colors.black : Colors.white)),
        onPressed: (!_hasSpeech
            ? null
            : (!transcriber.isListening ? startListening : stopListening)),
      ),
    );
  }

  DropdownButton getLangDropdown() {
    return DropdownButton(
      onChanged: (selectedVal) => _switchLang(selectedVal),
      value: _currentLocaleId,
      items: _localeNames
          .map(
            (localeName) => DropdownMenuItem(
              value: localeName.localeId,
              child: Text(localeName.name),
            ),
          )
          .toList(),
    );
  }

  Expanded getTranscription() {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: allWords,
                ),
                TextSpan(
                    text: (transcriber.isListening ? " " + lastWords : null),
                    style: TextStyle(
                      color: Colors.grey,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded getComments() {
    if (receivedMessages.isEmpty)
      return Expanded(
        child: Text("No Questions"),
      );
    return Expanded(
        child: SizedBox(
            height: 100.0,
            child: ListView.builder(
                itemCount: receivedMessages.length,
                itemBuilder: (BuildContext context, int idx) {
                  return Column(
                    children: [
                      Row(children: [
                        SizedBox(
                            width: 50,
                            height: 50,
                            child: const Icon(Icons.account_circle_rounded)),
                        Expanded(
                          child: Text('John Doe', textAlign: TextAlign.left),
                        ),
                        SizedBox(
                          child: IconButton(
                            iconSize: 30,
                            color: Colors.black,
                            icon: Icon(Icons.volume_mute),
                            //onPressed: ,
                          ),
                        ),
                        SizedBox(
                          child: IconButton(
                            iconSize: 30,
                            color: Colors.black,
                            icon: Icon(Icons.cancel),
                            //onPressed: ,
                          ),
                        ),
                      ]),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 5.0),
                        padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                        decoration: new BoxDecoration(
                            color: Colors.black12,
                            borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(30.0),
                                topRight: const Radius.circular(30.0),
                                bottomLeft: const Radius.circular(30.0),
                                bottomRight: const Radius.circular(30.0))),
                        child: Row(children: [
                          Expanded(
                            child: Text(
                                receivedMessages[idx],
                                textAlign: TextAlign.left,
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 1.2)),
                          ),
                        ]),
                      )
                    ],
                  );
                })));
  }

  AppBar getAppBar() {
    return AppBar(
        leading: GestureDetector(
          onTap: () { database.removeToken(sessionID); index = 0; setState(() {}); },
          child: Icon(Icons.exit_to_app),
        ),
        title: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Chat",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                sessionID,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 7, right: 7),
            child: getMicrophoneButton(),
          ),
        ]);
  }

  AppBar getAppBarSession() {
    return AppBar(
      title: const Text(
        "Speaker",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (index != 0 ? getAppBar() : getAppBarSession()),
        body: new Stack(children: <Widget>[
          Offstage(
            offstage: index != 0,
            child: new TickerMode(
              enabled: index == 0,
              child: new Scaffold(
                  body: new Center(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: sessionIDForm,
                      width: 150,
                    ),
                    FlatButton(
                      disabledTextColor: Colors.white,
                      disabledColor: Colors.white,
                      color: Colors.blue,
                      child: Text("Create Session"),
                      onPressed: checkSession,
                    ),
                  ],
                ),
              )),
            ),
          ),
          Offstage(
            offstage: index != 1,
            child: new TickerMode(
              enabled: index == 1,
              child: Column(
                children: [
                  getLangDropdown(),
                  getTranscription(),
                  Divider(
                    height: 20,
                    thickness: 5,
                    indent: 15,
                    endIndent: 15
                  ),
                  getComments(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    transcriber.startListening();
    setState(() {});
  }

  void stopListening() {
    transcriber.stopListening();
    setState(() {
      level = 0.0;
    });
  }

  void beginListener() {
    setState(() {});
  }

  void resultListener(TranscriberResult result) {
    print("resultListener: $result");
    if(result.isFinal()){
      messaging.sendMessageToSubscribers(result.getValue());
    }
    setState(() {
      lastWords = result.getValue();
      if (allWords == "" && lastWords != "")
        lastWords = "${lastWords[0].toUpperCase()}${lastWords.substring(1)}";
      if (result.isFinal() && lastWords != "") {
        if (allWords != "") allWords += " ";
        allWords += lastWords;
        lastWords = "";
      }
    });
  }

  void soundLevelListener(double level) {
    setState(() {
      this.level = level;
    });
  }

  void endListener() {
    setState(() {});
  }

  void errorListener(SpeechRecognitionError error) {
    print("errorListener: $error");
    if (error.errorMsg == "error_permission") showPermissionDialog();
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Insufficient permissions"),
        content: new Text(
            "You have insufficient permissions, please check you have provided all necessary permissions.\n"
            "You might also have trouble recognizing voice because "
            "you have not granted Google Speech Recognizer (part of Google Assistant) "
            "permission to record audio. "
            "If you have never started Google Assistant, starting it for the first time and granting "
            "permission to record audio should be enough."),
      ),
    );
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    transcriber.setLocale(_currentLocaleId);
    print(selectedVal);
  }
}
