import 'package:firebase_messaging/firebase_messaging.dart';
import 'Database.dart';

class Messaging{
  Future printToken() async{
    DataBase dataBase = new DataBase();
    String token = await FirebaseMessaging.instance.getToken();
    dataBase.addToken("speaker1", token);
    String out = dataBase.getToken("speaker1");
  }
  Messaging(void function(RemoteMessage)){
    printToken();
    FirebaseMessaging.onMessage.listen(function);
  }
  void sendMessage(String token,String message){

  }
  void subscribeSpeaker(String speakerToken,String token){

  }
}