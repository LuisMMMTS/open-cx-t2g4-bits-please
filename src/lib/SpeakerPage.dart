import 'dart:async';

import 'package:com_4_all/synthesizer/Synthesizer.dart';
import 'package:com_4_all/synthesizer/SynthesizerTextToSpeech.dart';
import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

import 'package:com_4_all/database/Database.dart';
import 'package:com_4_all/database/DatabaseFirebase.dart';
import 'package:com_4_all/messaging/Messaging.dart';
import 'package:com_4_all/messaging/MessagingFirebase.dart';
import 'package:com_4_all/transcriber/Transcriber.dart';
import 'package:com_4_all/transcriber/TranscriberResult.dart';
import 'package:com_4_all/transcriber/TranscriberSpeechToText.dart';
import 'package:split_view/split_view.dart';

class SpeakerPage extends StatefulWidget {
  final String title;
  SpeakerPage({Key key, this.title}) : super(key: key);
  @override
  _SpeakerPageState createState() => _SpeakerPageState();
}

class _SpeakerPageState extends State<SpeakerPage> {
  bool _hasSpeech = false;
  Transcriber transcriber;
  Synthesizer synthesizer;

  TextFormField sessionIDForm;
  var sessionIDController = new TextEditingController();
  String sessionID = "";
  String speakerToken = "";
  String talkTitle = "";
  int index = 0;
  List<dynamic> receivedMessages = new List<dynamic>();
  ScrollController scrollController =
  new ScrollController(initialScrollOffset: 50.0);

  double splitWeight = 0.7;

  Messaging messaging;

  Database database = new DatabaseFirebase();

  Future<void> initializeTranscriber() async {
    transcriber = TranscriberSpeechToText();
    transcriber.initialize(
        onBegin: beginListener,
        onResult: resultListener,
        onSoundLevel: soundLevelListener,
        onEnd: endListener,
        onError: errorListener);
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
    synthesizer = new SynthesizerTextToSpeech(stopPlayingSynthesizer);
    synthesizer.setLanguage("pt-PT");
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

  void stopPlayingSynthesizer(){

  }

  void getMessage(dynamic r) {
    setState(() {
      receivedMessages.add(r);
    });
    scrollController.animateTo(
        scrollController.position.maxScrollExtent.ceilToDouble() +
            receivedMessages.length * 20,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease);
  }

  Future setupMessaging() async {
    messaging = new MessagingFirebase(getMessage);
    speakerToken = await messaging.getToken();
  }

  Future checkSession() async {
    sessionID = sessionIDController.text;
    if (sessionID != "") {
      database.addToken(sessionID, speakerToken).then((status) async {
        String talkTitleTmp = await database.getTalkTitle(sessionID);
        setState(() {
          index = 1;
          talkTitle = talkTitleTmp;
        });
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (_) => new AlertDialog(
            title: new Text("No such talk ID"),
            content: new Text("There is no registered talk with that ID."),
          ),
        );
      }, test: (e) => e is NoSuchTalkException);
    } else {
      setState(() {
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
      });
    }
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

  Container getTranscription() {
    return Container(
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

  Container getComments() {
    if (receivedMessages.isEmpty)
      return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Text("No Questions",
            textAlign: TextAlign.center),
      );

    return Container(
        child: Column(children: [
          Expanded(
              child: SizedBox(
                  child: ListView.builder(
                      controller: scrollController,
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
                                  onPressed: () {
                                    synthesizer.startSynthesizer(receivedMessages[idx]['message']);
                                  },
                                ),
                              ),
                              SizedBox(
                                child: IconButton(
                                  iconSize: 30,
                                  color: Colors.black,
                                  icon: Icon(Icons.cancel),
                                  onPressed: () {
                                    setState(() {
                                      receivedMessages.removeAt(idx);
                                    });},
                                ),
                              ),
                            ]),
                            Container(
                              padding: EdgeInsets.fromLTRB(2.0, 0.2, 0.2, 0.2),
                              child: Text(receivedMessages[idx]['timestamp'],
                                  textAlign: TextAlign.right,
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .apply(fontSizeFactor: 0.8)),
                            ),
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
                                  child: Text(receivedMessages[idx]['message'],
                                      textAlign: TextAlign.left,
                                      style: DefaultTextStyle.of(context)
                                          .style
                                          .apply(fontSizeFactor: 1.2)),
                                ),
                              ]),
                            )
                          ],
                        );
                      }
                  )
              )
          )
        ]
        )
    );
  }

  AppBar getAppBar() {
    return AppBar(
        leading: GestureDetector(
          onTap: () {
            database.removeToken(sessionID);
            setState(() {
              index = 0;
              sessionID = null;
              talkTitle = null;
            });
          },
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
                talkTitle,
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
      title: Text(widget.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (index != 0 ? getAppBar() : getAppBarSession()),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return new Stack(
            children: <Widget>[
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
                            child: Text("Join session"),
                            onPressed: checkSession,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Offstage(
                offstage: index != 1,
                child: new TickerMode(
                  enabled: index == 1,
                  child: Column(
                    children: [
                      getLangDropdown(),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight,
                            maxWidth: constraints.maxWidth,
                          ),
                          child: SplitView(
                            initialWeight: splitWeight,
                            view1: getTranscription(),
                            view2: getComments(),
                            viewMode: SplitViewMode.Vertical,
                            onWeightChanged: (w) => splitWeight = w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void startListening() {
    setState(() {
      lastWords = "";
      lastError = "";
    });
    transcriber.startListening();
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

  void resultListener(TranscriberResult result) async {
    if (result.isFinal()) {
      List<String> subscribersTokens =
      await database.getSubscribersTokens(sessionID);
      messaging.sendMessageToList(subscribersTokens, result.getValue());
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