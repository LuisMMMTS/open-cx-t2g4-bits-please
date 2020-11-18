import 'package:com_4_all/database/Database.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseFirebase extends Database {
  final databaseReference = FirebaseDatabase.instance.reference();
  Future<bool> addToken(String talk_name, String token) async{
    if(talk_name == null || talk_name.length == 0){
      throw new DatabaseFirebaseIdNullError("talk_name pararmeter has a length of 0");
    }
    String localToken = "";
    localToken = await getToken(talk_name);
    print(localToken);
    if(localToken != null){
      return false;
    }
    databaseReference.child(talk_name).set({'token': token});

    return true;
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

class DatabaseFirebaseIdNullError extends DataBaseError{
  String error;
  DatabaseFirebaseIdNullError(this.error);
  String getError(){
    return error;
  }
}
