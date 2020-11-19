import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:com_4_all/Messaging/MessagingFirebase.dart';
import 'package:com_4_all/database/Database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';
import 'Messaging/Messaging.dart';
import 'SynthesizerTextToSpeech.dart';
import 'synthesizer/Synthesizer.dart';
import 'database/DatabaseFirebase.dart';

int index = 0;
double splitWeight = 0.7;
List<Widget> sentList = new List();

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
  List<DropdownMenuItem> languagesDropDownList = new List();
  String receivedText = "";

  Messaging messaging;

  Database database = new DatabaseFirebase();
  String sessionID = "";
  String localToken;
  String talkTitle = "";
  ScrollController transcriptScrollController =
      new ScrollController(initialScrollOffset: 50.0);
  ScrollController messagesScrollController =
      new ScrollController(initialScrollOffset: 50.0);

  Text receivedTextField() {
    return Text(
      receivedText,
      style: TextStyle(
        fontSize: 20,
      ),
      textAlign: TextAlign.left,
    );
  }

  SingleChildScrollView scrollView = SingleChildScrollView(
    scrollDirection: Axis.vertical, //.horizontal
    child: Text(""),
  );

  void getMessage(dynamic r) {
    String message = r.toString();
    if(receivedText.length>0)
      message = "\n" + message;
    receivedText += message;
    setState(() {});
    transcriptScrollController.animateTo(
        transcriptScrollController.position.maxScrollExtent.ceilToDouble() +
            receivedText.length,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease);
  }

  Future setupMessaging() async {
    messaging = new MessagingFirebase(getMessage);
    localToken = await messaging.getToken();
  }

  @override
  void initState() {
    super.initState();
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
  }

  Future checkSession() async {
    sessionID = sessionIDController.text;
    String speakerToken = await database.getToken(sessionIDController.text);
    if (speakerToken != null) {
      setState(() {
        index = 1;
      });
      database.subscribeTalk(sessionID, localToken);
      talkTitle = await database.getTalkTitle(sessionID);
    } else {
      sessionIDForm = TextFormField(
        controller: sessionIDController,
        decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: "Enter the session ID",
            errorText: "Wrong Session ID"),
        expands: false,
        maxLines: 1,
        minLines: 1,
      );
      sessionIDController.clear();
    }
    setState(() {});
  }

  Widget setMessageLayout(String messageText){
    return Container(
      margin: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
      padding: EdgeInsets.all(16.0),
      decoration: new BoxDecoration(
        color: Colors.black12,
        borderRadius: new BorderRadius.only(
          topLeft: const Radius.circular(30.0),
          topRight: const Radius.circular(30.0),
          bottomLeft: const Radius.circular(30.0),
          bottomRight: const Radius.circular(30.0),
        ),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(messageText, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage() async {
    messaging.sendMessage(
      await database.getToken(sessionID),
      questionMessageController.text
    );
    sentList.add(setMessageLayout(questionMessageController.text));
    print(questionMessageController.text.length);
    messagesScrollController.animateTo(
        messagesScrollController.position.maxScrollExtent.ceilToDouble() +
            questionMessageController.text.length * 100,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease);
    questionMessageController.clear();
    setState(() {});
  }

  AppBar getAppBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          database.unsubscribeTalk(sessionID, localToken);
          setState(() {
            index = 0;
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
    );
  }

  AppBar getAppBarSession() {
    return AppBar(
      title: Text(widget.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    scrollView = SingleChildScrollView(
      controller: transcriptScrollController,
      scrollDirection: Axis.vertical, //.horizontal
      child: receivedTextField(),
    );
    return Scaffold(
      appBar: (index != 0 ? getAppBar() : getAppBarSession()),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return new Stack(
            children: <Widget>[
              new Offstage(
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
                        SizedBox(
                          height: 20,
                        ),
                        FlatButton(
                          minWidth: 150,
                          disabledTextColor: Colors.white,
                          disabledColor: Colors.white,
                          color: Colors.blue,
                          child: Text("Enter the Session"),
                          onPressed: checkSession,
                        ),
                      ],
                    ),
                  )),
                ),
              ),
              new Offstage(
                offstage: index != 1,
                child: new TickerMode(
                  enabled: index == 1,
                  child: new Scaffold(
                    body: Column(
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight,
                              maxWidth: constraints.maxWidth,
                            ),
                            child: SplitView(
                              initialWeight: splitWeight,
                              view1: Container(
                                padding:
                                    EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                                child: scrollView,
                              ),
                              view2: SingleChildScrollView(
                                scrollDirection: Axis.vertical, //.horiz
                                controller: messagesScrollController, // ontal
                                child: Container(
                                  alignment: Alignment.topRight,
                                  padding:
                                      EdgeInsets.fromLTRB(0.0, 20.0, 0, 20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: sentList,
                                  ),
                                ),
                              ),
                              viewMode: SplitViewMode.Vertical,
                              onWeightChanged: (w) => splitWeight = w,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
                                decoration: new BoxDecoration(
                                  color: Colors.black12,
                                ),
                                child: questionMessage,
                              ),
                            ),
                            IconButton(
                              color: Colors.black,
                              splashColor: Colors.blue,
                              icon: Icon(Icons.send),
                              onPressed: sendMessage,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
