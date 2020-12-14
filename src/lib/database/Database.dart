/// Class used to manage the database, more specifically the tokens
abstract class Database {
  /// Function that adds the token of an attendee as a child of the speaker token of talk talk_id
  /// @param talk_id Talk ID
  /// @param token attendee token
  /// @param code Talk code
  /// @return whether tha addition was successful
  Future<bool> addToken(String talkID, String token, String code);

  /// Function that returns the token of speaker with talk_name
  /// @param talk_id Talk ID
  /// @return returns the token of the speaker as a String
  Future<String> getToken(String talkID);

  /// Deletes the token of a speaker with name talk_name
  /// @param talk_name Talk ID
  void removeToken(String talkID);

  /// Get talk title from talk ID.
  /// @param talk_id Talk ID
  /// @return Title of the talk
  Future<String> getTalkTitle(String talkID);

  /// Get talk code from talk ID.
  /// @param talk_id Talk ID
  /// @return Code of the talk
  Future<String> getTalkCode(String talkID);

  /// Subscribes an attendee to the talk indicated 
  /// @param talkID Talk ID
  /// @param token token of the attendee
  Future<void> subscribeTalk(String talkID, String token);

  /// unsubscribes an attendee from a talk 
  /// @param talkID Talk ID
  /// @param token token of the attendee to be unsubscribed
  Future<void> unsubscribeTalk(String talkID, String token);

  /// Get tokens of people that subscribed a talk.
  /// @param talkID Talk ID
  /// @return List of subscribers' tokensW
  Future<List<String>> getSubscribersTokens(String talkID);
}

abstract class DataBaseError{
  String getError();
}

class NoSuchTalkException implements Exception {
  final String msg;
  const NoSuchTalkException([this.msg = ""]);
  String toString() => 'NoSuchTalkException: $msg';
}
