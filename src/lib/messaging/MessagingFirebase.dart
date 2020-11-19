import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'Messaging.dart';

class MessagingFirebase extends Messaging {
  MessageCallback callback;
  String token;
  List<String> subscribersList = new List();
  String authorization =
      'key=AAAAAEzH8OQ:APA91bGsGHOn9VJPXP2pj0jdtcHJ1O0475jjAC04wG6eQRkuwAd6v0auhxPMUSt_9kTt2XfCC70hcdh60tfKEIr-6UYqectCtEocmOkamk3D_hnSBeffuAd3nUtdHPcu58kgfhDJQQP9';

  Future handleSubscriber(String token) async {
    subscribersList.add(token);
  }

  void processMessage(RemoteMessage remoteMessage) {
    if (remoteMessage.data['type'] == 'subscribe') {
      handleSubscriber(remoteMessage.data['token']);
    }
    if (remoteMessage.from.isNotEmpty &&
        remoteMessage.data['type'] == 'message') {
      callback(remoteMessage.data["message"]);
    }
  }

  MessagingFirebase(MessageCallback function) {
    this.callback = function;
    getToken();
    FirebaseMessaging.onMessage.listen(processMessage);
  }

  void sendMessage(String token, String message) async {
    http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': authorization,
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': '', 'title': ''},
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

  Future<String> getToken() async {
    String out = await FirebaseMessaging.instance.getToken();
    token = out;
    return out;
  }
}
