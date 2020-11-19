import 'package:com_4_all/database/Database.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseFirebase extends Database {
  final databaseReference = FirebaseDatabase.instance.reference();
  Future<bool> addToken(String talkId, String token) async{
    if(talkId == null || talkId.length == 0){
      throw new DatabaseFirebaseIdNullError("talkId pararmeter has a length of 0");
    }
    String localToken = "";
    localToken = await getToken(talkId);
    print(localToken);
    if(localToken != null){
      return false;
    }
    databaseReference.child("talks").child(talkId).update({'token': token});
    return true;
  }

  Future<String> getToken(String talkId) async {
    if(talkId.length <= 0){
      throw FormatException("talkId can not be empty");
    }
    String out;
    out = await databaseReference
        .child("talks")
        .child(talkId)
        .child("token")
        .once()
        .then((DataSnapshot snapshot) {
      return snapshot.value;
    });
    return out;
  }

  void removeToken(String talkId) {
    databaseReference
      .child("talks")
      .child(talkId)
      .child("token")
      .remove();
  }

  Future<String> getTalkTitle(String talkId) async {
    String out;
    out = await databaseReference
      .child("talks")
      .child(talkId)
      .child("title")
      .once()
      .then((DataSnapshot snapshot){
        return snapshot.value;
      });
      return out;
  }

  void subscribeTalk(String talkID, String token){
    print("subscribeTalk, " + talkID);
    if(talkID == null || talkID.length == 0){
      throw new DatabaseFirebaseIdNullError("talkID pararmeter has a length of 0");
    }
    databaseReference
      .child("talks")
      .child(talkID)
      .child("subscribers")
      .push()
      .set(token);
  }
  
  void unsubscribeTalk(String talkID, String token) async {
    print("subscribeTalk, " + talkID);
    if(talkID == null || talkID.length == 0){
      throw new DatabaseFirebaseIdNullError("talkID pararmeter has a length of 0");
    }
    Map<dynamic, dynamic> subscribers = await databaseReference
      .child("talks")
      .child(talkID)
      .child("subscribers")
      .once()
      .then((DataSnapshot snapshot) {
        return snapshot.value;
    });

    String key = subscribers.keys.firstWhere((k) => subscribers[k] == token, orElse: () => null);
    if(key != null){
      databaseReference
        .child("talks")
        .child(talkID)
        .child("subscribers")
        .child(key)
        .remove();
    }
  }

  Future<List<String>> getSubscribersTokens(String talkID) async{
    if(talkID == null || talkID.length == 0){
      throw new DatabaseFirebaseIdNullError("talkID pararmeter has a length of 0");
    }
    Map<dynamic, dynamic> out = await databaseReference
      .child("talks")
      .child(talkID)
      .child("subscribers")
      .once()
      .then((DataSnapshot snapshot) {
        return snapshot.value;
    });
    List<String> ret = List<String>.from(out.values);
    return ret;
  }
}

class DatabaseFirebaseIdNullError extends DataBaseError{
  String error;
  DatabaseFirebaseIdNullError(this.error);
  String getError(){
    return error;
  }
}
