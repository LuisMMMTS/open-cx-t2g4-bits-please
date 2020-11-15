import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'Messaging.dart';

/*
Como usar:
  Normal User
    DatabaseFirebase database = new DatabaseFirebase();
    Messaging messaging = new MessagingFirebase(<funcao que recebe o parametro data do tipo String>);
    String speakertoken = database.getToken("<speaker_name>");

    String localToken = await messaging.getToken();
    messaging.subscribeSpeaker(speakertoken, localToken);

    //para enviar mensagem
    messaging.sendMessage(speakertoken, message);


  Speaker:
    DatabaseFirebase database = new DatabaseFirebase();
    Messaging messaging = new MessagingFirebase(<funcao que recebe o parametro data do tipo String>);

    String localToken = await messaging.getToken();
    database.addToken(speakerName,localToken);

    //para enviar mensagem
    messaging.sendMessageToSubscribers(message);
 */


typedef void VoidCallback(String);

class MessagingFireBase extends Messaging{
  int subscribers = 0;
  VoidCallback callback;
  String token;
  String speakerName;

  Future handleSubscriber(String token, String speaker) async{
    http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAAEzH8OQ:APA91bGsGHOn9VJPXP2pj0jdtcHJ1O0475jjAC04wG6eQRkuwAd6v0auhxPMUSt_9kTt2XfCC70hcdh60tfKEIr-6UYqectCtEocmOkamk3D_hnSBeffuAd3nUtdHPcu58kgfhDJQQP9',
      },
      body: jsonEncode(
          {
            "operation": "add",
            "notification_key_name": speaker,
            "notification_key": token.substring(20,30),
            "registration_ids": [subscribers.toString()]
          }
      ),
    );
  }

  void processMessage(RemoteMessage remoteMessage){
    if(remoteMessage.data['type']=='subscribe'){
      handleSubscriber(remoteMessage.data['token'], token);
    }
    if(remoteMessage.from.isNotEmpty && remoteMessage.data['type']=='message'){
      print(remoteMessage.from);
      callback(remoteMessage.data["message"]);
    }
  }

  MessagingFireBase(void function(String),String speakerName){
    this.callback = function;
    this.speakerName = speakerName;
    getToken();
    FirebaseMessaging.onMessage.listen(processMessage);
  }

  void sendMessage(String token,String message) async{
    http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAAEzH8OQ:APA91bGsGHOn9VJPXP2pj0jdtcHJ1O0475jjAC04wG6eQRkuwAd6v0auhxPMUSt_9kTt2XfCC70hcdh60tfKEIr-6UYqectCtEocmOkamk3D_hnSBeffuAd3nUtdHPcu58kgfhDJQQP9',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '',
            'title': ''
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'type': 'message',
            'message': message
          },
          'to': token,
        },
      ),
    );
  }
  void subscribeSpeaker(String speakerToken,String token){
    http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAAEzH8OQ:APA91bGsGHOn9VJPXP2pj0jdtcHJ1O0475jjAC04wG6eQRkuwAd6v0auhxPMUSt_9kTt2XfCC70hcdh60tfKEIr-6UYqectCtEocmOkamk3D_hnSBeffuAd3nUtdHPcu58kgfhDJQQP9',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '',
            'title': ''
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'type': 'subscribe',
            'token': token
          },
          'to': speakerToken,
        },
      ),
    );
  }
  void sendMessageToSubscribers(String message){
    http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAAEzH8OQ:APA91bGsGHOn9VJPXP2pj0jdtcHJ1O0475jjAC04wG6eQRkuwAd6v0auhxPMUSt_9kTt2XfCC70hcdh60tfKEIr-6UYqectCtEocmOkamk3D_hnSBeffuAd3nUtdHPcu58kgfhDJQQP9',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '',
            'title': ''
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'type': 'message',
            'message': message
          },
          'to': token,
        },
      ),
    );
  }
  Future<String> getToken() async{
    String out = await FirebaseMessaging.instance.getToken();
    print(out);
    token = out;
    return out;
  }
}