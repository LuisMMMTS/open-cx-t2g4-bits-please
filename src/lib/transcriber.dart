import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class TranscriberPage extends StatefulWidget {
  final String title;
  TranscriberPage({Key key, this.title}) : super(key: key);
  @override
  _TranscriberPageState createState() => _TranscriberPageState();
}

class _TranscriberPageState extends State<TranscriberPage> {
  bool _hasSpeech = false;
  SpeechToText transcriber = SpeechToText();
  Future<void> TranscriberCtor() async {
    if(!_hasSpeech) {
      bool hasSpeech = await transcriber.initialize(
          onError: errorListener,
          onStatus: statusListener
      );
      if (hasSpeech) {
        _localeNames = await transcriber.locales();

        var systemLocale = await transcriber.systemLocale();
        _currentLocaleId = systemLocale.localeId;
      }

      if (!mounted) return;

      setState(() {
        _hasSpeech = hasSpeech;
      });
    }
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
    TranscriberCtor();
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
        ],
      ),
    );
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    transcriber.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 20),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    transcriber.stop();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      if(allWords == "") lastWords = "${lastWords[0].toUpperCase()}${lastWords.substring(1)}";
      if(result.finalResult && lastWords != "") {
        if(allWords != "") allWords += " ";
        allWords += lastWords;
      }
    });
  }

  void soundLevelListener(double level) {
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${transcriber.isListening}");
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    print("Received listener status: $status, listening: ${transcriber.isListening}");
    setState(() {
      lastStatus = "$status";
    });
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
}
