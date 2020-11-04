import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(SynthesizerPage());

class SynthesizerPage extends StatefulWidget {
  SynthesizerPage({Key key, this.title}) : super(key: key);


  final String title;
  @override
  _SynthesizerPageState createState() => _SynthesizerPageState();
}

enum TtsState { playing, stopped, paused, continued }



class _SynthesizerPageState extends State<SynthesizerPage> {
  FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;
  List<dynamic> languagesDynamic;
  List<DropdownMenuItem<dynamic>> languages = new List();
  String language = null;

  Future _speak() async{
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.7);
    await flutterTts.setPitch(1.0);
    var result = await flutterTts.speak("Hello World");
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async{
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _getLanguages() async {
    languagesDynamic = await flutterTts.getLanguages;
    for(var language in languagesDynamic){
      languages.add(new DropdownMenuItem(
        value: language,
        child: Text(language),
      ));
    }
    language = languagesDynamic.first;
    languages.sort((a, b) => a.value.compareTo(b.value));
    if (languagesDynamic != null) setState(() => languagesDynamic);
  }

  void onSelectedLanguageChanged(dynamic){
    language = dynamic;
    setState(() {

    });
  }

  Future _setLang() async {
      if(await flutterTts.isLanguageAvailable("en-US")){
        language = "en-US";
      }
      else if(await flutterTts.isLanguageAvailable("pt-PT")){
        language = "pt-PT";
      }
  }

  Container Speaker(){
    return new Container(
      decoration: ShapeDecoration(
          color: (ttsState==TtsState.playing ? Colors.white : Colors.red ),
          shape: CircleBorder()
      ),
      child: IconButton(
        color: (ttsState==TtsState.playing ? Colors.black : Colors.white ),
        splashColor: (ttsState==TtsState.playing ? Colors.black : Colors.white ),
        icon: Icon(Icons.speaker_phone),
        onPressed: (ttsState==TtsState.playing ? _stop : _speak),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        ttsState = TtsState.continued;
      });
    });
    _getLanguages();
    _setLang();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.title),
            Speaker(),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        )

      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child:
              DropdownButton<dynamic>(
                items: languages,
                onChanged: onSelectedLanguageChanged,
                value: language,
              ),
          )
        ],
      ),
    );
  }
}
