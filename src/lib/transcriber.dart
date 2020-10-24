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
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String allWords = "";
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
  }

  Future<void> initSpeechState() async {
    if(!_hasSpeech) {
      bool hasSpeech = await speech.initialize(
          onError: errorListener, onStatus: statusListener);
      if (hasSpeech) {
        _localeNames = await speech.locales();

        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale.localeId;
      }

      if (!mounted) return;

      setState(() {
        _hasSpeech = hasSpeech;
      });
    }
  }

  Container getMicrophoneButton(){
    return Container(
      width: 40,
      decoration: ShapeDecoration(
        shadows: [
          BoxShadow(
            blurRadius: .1,
            spreadRadius: (speech.isListening ? level : 0) * 1.0,
            color: Colors.red.withOpacity(.50),
          ),
        ],
        color: (!_hasSpeech ? Colors.grey : (!speech.isListening ? Colors.white : Colors.red)),
        shape: CircleBorder(),
      ),
      child: IconButton(
        icon: Icon(Icons.mic),
        color: (!_hasSpeech ? Colors.grey : (!speech.isListening ? Colors.black : Colors.white)),
        onPressed: (!_hasSpeech ? null : (!speech.isListening ? startListening : stopListening)),
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
    initSpeechState();
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
                        text: (speech.isListening ? " " + lastWords : null),
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
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 20),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      if(result.finalResult && lastWords != "") {
        if(allWords != "") allWords += " ";
        allWords += lastWords;
        allWords = "${allWords[0].toUpperCase()}${allWords.substring(1)}";
      }
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    print("Received listener status: $status, listening: ${speech.isListening}");
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
