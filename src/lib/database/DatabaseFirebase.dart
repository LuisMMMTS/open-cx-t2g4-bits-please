import 'package:com_4_all/database/Database.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseFirebase extends Database {
  final databaseReference = FirebaseDatabase.instance.reference();
  void addToken(String talk_name, String token) {
    databaseReference.child(talk_name).set({'token': token});
    ;
  }

  Future<String> getToken(String talk_name) async {
    String out;
    out = await databaseReference
        .child(talk_name)
        .child("token")
        .once()
        .then((DataSnapshot snapshot) {
      return snapshot.value;
    });
    return out;
  }

  void removeToken(String talk_name) {
    databaseReference.child(talk_name).remove();
  }
}
