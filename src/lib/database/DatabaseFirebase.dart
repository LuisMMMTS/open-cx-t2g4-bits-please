import 'package:com_4_all/database/Database.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseFirebase extends Database{
  final databaseReference = FirebaseDatabase.instance.reference();
  void addToken(String speaker_name,String token){
    databaseReference.child(speaker_name).set({
      'token': token
    });
    ;
  }
  Future<String> getToken(String speaker_name) async{
    String out;
    out = await databaseReference.child(speaker_name).child("token").once().then((DataSnapshot snapshot) {
      return snapshot.value;
    });
    return out;
  }
  void removeToken(String speaker_name){
    databaseReference.child(speaker_name).remove();
  }
}