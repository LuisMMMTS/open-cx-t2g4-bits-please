import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'Messaging/Messaging.dart';
import 'SynthesizerTextToSpeech.dart';
import 'Synthesizer.dart';
import 'database/DatabaseFirebase.dart';

void main() => runApp(SynthesizerPage());

class SynthesizerPage extends StatefulWidget {
  SynthesizerPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _SynthesizerPageState createState() => _SynthesizerPageState();
}

class _SynthesizerPageState extends State<SynthesizerPage> {
  TextField textForm;
  var textFormController = new TextEditingController();
  Synthesizer synthesizer;
  List<DropdownMenuItem> languagesDropDownList = new List();

  Container Speaker(){
    return new Container(
      decoration: ShapeDecoration(
          color: (synthesizer.isPlaying() ? Colors.white : Colors.red ),
          shape: CircleBorder()
      ),
      child: IconButton(
        color: (synthesizer.isPlaying() ? Colors.black : Colors.white ),
        splashColor: (synthesizer.isPlaying() ? Colors.black : Colors.white ),
        icon: Icon(Icons.speaker_phone),
        onPressed: (synthesizer.isPlaying() ? synthesizer.stopSynthesizer : startPlaying),
      ),
    );
  }

  void get(RemoteMessage r){}

  @override
  void initState() {
    super.initState();
    synthesizer = new SynthesizerTextToSpeech(stopPlaying);
    textForm = TextField(
      controller: textFormController,
      decoration: InputDecoration(
        hintText: "Enter a message to synthesize",
      ),
      expands: true,
      maxLines: null,
      minLines: null,
    );
    setupLanguagesDropdown();

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
      body:
      Container(
        padding: EdgeInsets.all(16.0),
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child:
              DropdownButton<dynamic>(
                items: languagesDropDownList,
                onChanged: onSelectedLanguageChanged,
                value: synthesizer.getLanguage(),
              ),
            ),

            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                padding: EdgeInsets.all(16.0),
                child: textForm
              ),
            ),
          ],
        ),
      ),
    );
  }

  void stopPlaying(){
    setState(() {
    });
  }
  Future startPlaying() async{
    synthesizer.startSynthesizer(textFormController.text);
    textFormController.clear();
    print(synthesizer.isPlaying());
    setState(() {});
  }

  void onSelectedLanguageChanged(dynamic language){
    synthesizer.setLanguage(language.toString());
    setState(() {});
  }

  Future setupLanguagesDropdown() async{
    for(var l in await synthesizer.getLanguages()){
      languagesDropDownList.add(
          new DropdownMenuItem(
            value: l.toString(),
            child:
            Text(l.toString()),
          )
      );
    }
    setState(() {
    });
  }
}
