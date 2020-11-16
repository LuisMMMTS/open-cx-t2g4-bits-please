import 'dart:async';
import 'dart:io';

import 'package:com_4_all/Messaging/MessagingFirebase.dart';
import 'package:com_4_all/database/Database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'Messaging/Messaging.dart';
import 'SynthesizerTextToSpeech.dart';
import 'synthesizer/Synthesizer.dart';
import 'database/DatabaseFirebase.dart';

int index = 0;

class SynthesizerPage extends StatefulWidget {
  SynthesizerPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _SynthesizerPageState createState() => _SynthesizerPageState();
}

class _SynthesizerPageState extends State<SynthesizerPage> {
  TextField questionMessage;
  TextFormField sessionIDForm;
  var questionMessageController = new TextEditingController();
  var sessionIDController = new TextEditingController();
  //Synthesizer synthesizer;
  List<DropdownMenuItem> languagesDropDownList = new List();
  String receivedText = "";

  Messaging messaging;

  Database database = new DatabaseFirebase();
  String sessionID = "";
  String speakerToken = "";
  String localToken ;
  ScrollController scrollController = new ScrollController(initialScrollOffset: 50.0);

  /*Container Speaker(){
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
  }*/

  Text receivedTextField(){
    return Text(
      receivedText,
      textAlign: TextAlign.left,
    );
  }
  SingleChildScrollView scrollView = SingleChildScrollView(
    scrollDirection: Axis.vertical,//.horizontal
    child: Text(""),
  );

  void getMessage(dynamic r){
    receivedText += r.toString();
    //questionMessageController.text = r.toString();
    setState(() {
    });
    scrollController.animateTo(scrollController.position.maxScrollExtent.ceilToDouble()+receivedText.length,
      duration: Duration(milliseconds: 500),
      curve: Curves.bounceIn
    );
  }

  Future setupMessaging() async{
    messaging = new MessagingFirebase(getMessage);
    localToken = await messaging.getToken();
  }

  @override
  void initState() {
    super.initState();
    //synthesizer = new SynthesizerTextToSpeech(stopPlaying);
    setupMessaging();

    questionMessage = TextField(
      controller: questionMessageController,
      decoration: InputDecoration(
        hintText: "Enter a Question to ask",
      ),
      expands: false,
      maxLines: 5,
      minLines: 1,
    );
    sessionIDForm = TextFormField(
      controller: sessionIDController,
      decoration: InputDecoration(
        labelText: "Enter the session ID",
      ),
      expands: false,
      maxLines: 1,
      minLines: 1,
    );
    //setupLanguagesDropdown();
  }

  Future checkSession() async{
    speakerToken = await database.getToken(sessionIDController.text);
    if(speakerToken!=null) {
      index = 1;
      sessionID = sessionIDController.text;
      messaging.subscribeSpeaker(speakerToken,localToken);
      print(localToken);
    }
    else{
      sessionIDForm = TextFormField(
        controller: sessionIDController,
        decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: "Enter the session ID",
            errorText: "Wrong Session ID"
        ),
        expands: false,
        maxLines: 1,
        minLines: 1,
      );
      sessionIDController.clear();
    }
    setState(() {

    });
  }

  void sendMessage(){
    messaging.sendMessage(speakerToken, questionMessageController.text);
    print(speakerToken);
    print(localToken);
    questionMessageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    scrollView = SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.vertical,//.horizontal
      child: receivedTextField(),
    );

    return Scaffold(
      body: new Stack(
        children: <Widget>[
          new Offstage(
            offstage: index != 0,
            child: new TickerMode(
              enabled: index == 0,
              child:
              new Scaffold(
                  appBar: AppBar(
                    title: Text(widget.title),
                  ),
                  body:   new Center(
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
                          child: Text("Enter the Session"),
                          onPressed: checkSession,
                        ),
                      ],
                    ),
                  )
              ),
            ),
          ),
          new Offstage(
            offstage: index != 1,
            child: new TickerMode(
              enabled: index == 1,
              child: new Scaffold(
                appBar: AppBar(
                    title: Row(
                      children: [
                        Text(widget.title),
                        //Speaker(),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    )

                ),
                body:
                Container(
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /*Center(
                        child:
                        DropdownButton<dynamic>(
                          items: languagesDropDownList,
                          onChanged: onSelectedLanguageChanged,
                          value: synthesizer.getLanguage(),
                        ),
                      ),*/
                      Expanded(
                          child:
                          /*Container(
                          padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                          child: receivedTextField(),
                        ),*/
                          Container(
                            padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child:  scrollView,
                          )
                      ),
                      Row(
                          children: [
                            Expanded(
                              child:
                              Container(
                                padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
                                decoration: new BoxDecoration(
                                  color:  Colors.black12,
                                ),
                                child: questionMessage,
                              ),
                            ),
                            IconButton(
                              color: Colors.black,
                              splashColor:  Colors.blue,
                              icon: Icon(Icons.send),
                              onPressed: sendMessage,
                            ),
                          ]
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

/*
  void stopPlaying(){
    setState(() {
    });
  }
  Future startPlaying() async{
    synthesizer.startSynthesizer(questionMessageController.text);
    questionMessageController.clear();
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
  }*/
}
