typedef void MessageCallback(String string);

/*
* Class used to subscribe attendees and send messages in both directions
*/
abstract class Messaging{

  /*
  * Sends a message to the token indicated on token param
  * @param token token to send the message to
  * @param message string with the message
  */
  void sendMessage(String token, String message);

  /*
  * Sends a message to each token of a list.
  * @param token token to send the message to
  * @param message content of the message
  */
  void sendMessageToList(List<String> tokens, String message){
    tokens.forEach((token) => this.sendMessage(token, message));
  }

  /*
  * Receives the token current device
  * @return token
  */
  Future<String> getToken();
}