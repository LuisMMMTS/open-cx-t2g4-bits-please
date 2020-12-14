import 'package:com_4_all/database/Database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DatabaseFirebase extends Database {
  final databaseReference = FirebaseDatabase.instance.reference();

  Future<bool> _existsTalkID(String talkID) async {
    bool ret = await databaseReference
      .child("talks")
      .child(talkID)
      .once()
      .then((DataSnapshot snapshot) {
        return (snapshot.value != null);
      });
      return ret;
  }

  Future<bool> addToken(String talkID, String token, String code) async{
    if(talkID == null || talkID.length == 0){
      throw new DatabaseFirebaseIdNullError("talkID parameter has a length of 0");
    }
    bool talkIDExists = await _existsTalkID(talkID);
    if(!talkIDExists){
      throw new NoSuchTalkException("No such talk " + talkID);
    }

    String talkCode = "";
    talkCode = await getTalkCode(talkID);
    if(talkCode != code)
      throw new NoSuchTalkException("Invalid code");

    String localToken = "";
    localToken = await getToken(talkID);
    if(localToken != null){
      return false;
    }
    databaseReference.child("talks").child(talkID).update({'token': token});
    return true;
  }

  Future<String> getToken(String talkID) async {
    if(talkID.length <= 0){
      throw FormatException("talkID can not be empty");
    }
    String out = await databaseReference
        .child("talks")
        .child(talkID)
        .child("token")
        .once()
        .then((DataSnapshot snapshot) {
      return snapshot.value;
    });
    return out;
  }

  Future<void> removeToken(String talkID) async {
    if(talkID == null || talkID.length == 0){
      throw new DatabaseFirebaseIdNullError("talkID parameter has a length of 0");
    }
    bool talkIDExists = await _existsTalkID(talkID);
    if(!talkIDExists){
      throw new NoSuchTalkException("No such talk " + talkID);
    }
    databaseReference
      .child("talks")
      .child(talkID)
      .child("token")
      .remove();
  }

  Future<String> getTalkTitle(String talkID) async {
    String out;
    out = await databaseReference
      .child("talks")
      .child(talkID)
      .child("title")
      .once()
      .then((DataSnapshot snapshot){
        return snapshot.value;
      });
      return out;
  }

  Future<String> getTalkCode(String talkID) async {
    String out;
    out = await databaseReference
        .child("talks")
        .child(talkID)
        .child("code")
        .once()
        .then((DataSnapshot snapshot){
      return snapshot.value;
    });
    print(out);
    return out;
  }

  Future<void> subscribeTalk(String talkID, String token) async{
    if(talkID == null || talkID.length == 0){
      throw new DatabaseFirebaseIdNullError("talkID parameter has a length of 0");
    }
    bool talkIDExists = await _existsTalkID(talkID);
    if(!talkIDExists){
      throw new NoSuchTalkException("No such talk " + talkID);
    }
    databaseReference
      .child("talks")
      .child(talkID)
      .child("subscribers")
      .push()
      .set(token);
  }
  
  Future<void> unsubscribeTalk(String talkID, String token) async {
    if(talkID == null || talkID.length == 0){
      throw new DatabaseFirebaseIdNullError("talkID parameter has a length of 0");
    }
    bool talkIDExists = await _existsTalkID(talkID);
    if(!talkIDExists){
      throw new NoSuchTalkException("No such talk " + talkID);
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
      throw new DatabaseFirebaseIdNullError("talkID parameter has a length of 0");
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
