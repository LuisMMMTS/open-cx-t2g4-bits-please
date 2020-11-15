import 'dart:convert';

import 'package:com_4_all/database/DatabaseFirebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'database/Database.dart';
import 'package:http/http.dart' as http;


typedef void VoidCallback(RemoteMessage);

class Messaging{
  VoidCallback callback;
  void receiveFunction(RemoteMessage remoteMessage){
    if(remoteMessage.from.isNotEmpty && remoteMessage.data['type']=='message'){
      print(remoteMessage.from);
      callback(remoteMessage.data["message"]);
    }
  }
  Messaging(void function(RemoteMessage)){
    this.callback = function;
    FirebaseMessaging.onMessage.listen(receiveFunction);
  }
  Future sendMessage(String token,String message) async{
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

  }
  void sendMessageToSubscribers(){

  }
  Future<String> getToken() async{
    String out = await FirebaseMessaging.instance.getToken();
    print(out);
    return out;
  }
}