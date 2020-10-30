import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import 'Transcriber.dart';
import 'TranscriberSpeechToText.dart';

class TranscriberPage extends StatefulWidget {
  final String title;
  TranscriberPage({Key key, this.title}) : super(key: key);
  @override
  _TranscriberPageState createState() => _TranscriberPageState();
}

class _TranscriberPageState extends State<TranscriberPage> {
  bool _hasSpeech = false;
  Transcriber transcriber;


  Future<void> initializeTranscriber() async {
    transcriber = TranscriberSpeechToText(
      onBegin: beginListener,
      onResult: resultListener,
      onSoundLevel: soundLevelListener,
      onEnd: endListener,
      onError: errorListener,
    );
    bool hasSpeech = await transcriber.initSpeech();
    if (hasSpeech) {
      print("Initialized voice recognition\n");
      _localeNames = await transcriber.getLocales();

      var systemLocale = await transcriber.getSystemLocale();
      _currentLocaleId = systemLocale.localeId;
    }else{
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
  }

  Container getMicrophoneButton(){
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
        color: (!_hasSpeech ? Colors.grey : (!transcriber.isListening ? Colors.white : Colors.red)),
        shape: CircleBorder(),
      ),
      child: IconButton(
        icon: Icon(Icons.mic),
        color: (!_hasSpeech ? Colors.grey : (!transcriber.isListening ? Colors.black : Colors.white)),
        onPressed: (!_hasSpeech ? null : (!transcriber.isListening ? startListening : stopListening)),
      ),

    );
  }

  Column getComments(){
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child:
                const Icon(Icons.account_circle_rounded)
            ),
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
          ]
        ),
        Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          padding: EdgeInsets.all(16.0),
          decoration: new BoxDecoration(
              color:  Colors.black12,
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(30.0),
                  topRight: const Radius.circular(30.0),
                  bottomLeft: const Radius.circular(30.0),
                  bottomRight: const Radius.circular(30.0))),
        child: Row(
            children:[
              Expanded(
                child: Text(
                  'Hello, I have a question regarding voice transcription. What languages are available?',
                  textAlign: TextAlign.center),
              ),
            ]
        ),
        )
      ],
    );
  }

  AppBar getAppBar(){
    return AppBar(
      title: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Chat",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Conferencing 101",
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 7, right: 7),
          child: getMicrophoneButton(),
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Column(
        children: [
          DropdownButton(
            onChanged: (selectedVal) => _switchLang(selectedVal),
            value: _currentLocaleId,
            items: _localeNames
              .map(
                (localeName) => DropdownMenuItem(
                  value: localeName.localeId,
                  child: Text(localeName.name),
                ),
              ).toList(),
            ),
          Expanded(
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
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          getComments(),
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

  void beginListener(String status) {
    print("beginListener: $status");
    setState(() {});
  }

  void resultListener(SpeechRecognitionResult result) {
    print("resultListener: $result");
    setState(() {
      lastWords = result.recognizedWords;
      if(allWords == "" && lastWords != "") lastWords = "${lastWords[0].toUpperCase()}${lastWords.substring(1)}";
      if(result.finalResult && lastWords != "") {
        if(allWords != "") allWords += " ";
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

  void endListener(String status) {
    print("endListener: $status");
    setState(() {});
  }

  void errorListener(SpeechRecognitionError error) {
    print("errorListener: $error");
    if(error.errorMsg == "error_permission") showPermissionDialog();
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void showPermissionDialog(){
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
            "permission to record audio should be enough."
        ),
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
