/// Class used to manage the database, more specifically the tokens
abstract class Database {
  /// Function that adds the token of an atendee as a child of the speaker token of talk talk_id
  /// @param talk_id Talk ID
  /// @param token atendee token
  /// @return whether tha addition was successful
  Future<bool> addToken(String talkId, String token);

  /// Function that returns the token of speaker with talk_name
  /// @param talk_id Talk ID
  /// @return returns the token of the speaker as a String
  Future<String> getToken(String talkId);

  /// Deletes the token of a speaker with name talk_name
  /// @param talk_name Talk ID
  void removeToken(String talkId);

  /// Get talk title from talk ID.
  /// @param talk_id Talk ID
  /// @return Title of the talk
  Future<String> getTalkTitle(String talkId);

  /// Subscribes an atendee to the talk indicated 
  /// @param talkID Talk ID
  /// @param token token of the atendee
  void subscribeTalk(String talkID, String token);

  /// Get tokens of people that subscribed a talk.
  /// @param talkID Talk ID
  /// @return List of subscribers' tokensW
  Future<List<String>> getSubscribersTokens(String talkID);
}

abstract class DataBaseError{
  String getError();
}
