/*
* Class used to manage the database, more specifically the tokens
*/
abstract class Database {
  /*
  * Function that adds the token of an atendee as a child of the speaker token of name talk_name
  * @param talk_name name of the speaker
  * @param token atendee token
  * @return whether tha addition was successful
  */
  Future<bool> addToken(String talk_name, String token);

  /*
  * Function that returns the token of speaker with speaker_name
  * @param speaker_name name of speaker
  * @return returns the token of the speaker as a String
  */
  Future<String> getToken(String talk_name);

  /*
  * Deletes the token of a speaker with name speaker_name
  * @param speaker_name name of the speaker
  */
  void removeToken(String talk_name);
}
