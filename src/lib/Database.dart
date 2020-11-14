import 'package:firebase_database/firebase_database.dart';

class DataBase{
  final databaseReference = FirebaseDatabase.instance.reference();
  void addToken(String speaker_name,String token){
    databaseReference.child(speaker_name).set({
      'token': token
    });
    ;
  }
  String getToken(String speaker_name){
    String out;
    databaseReference.child(speaker_name).child("token").once().then((DataSnapshot snapshot) {
      out = snapshot.value;
    });
    return out;
  }
}