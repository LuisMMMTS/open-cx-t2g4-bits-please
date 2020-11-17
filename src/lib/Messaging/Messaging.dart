typedef void VoidCallback(String);

/*
* Class used to subscribe atendees and send messages in both directions
*/
abstract class Messaging{

  /*
  * Sends a message to the token indicated on token param
  * @param token token to send the message to
  * @param message string with the message
  */
  void sendMessage(String token,String message);

  /*
  * Subscribes an atendee to the speaker indicated 
  * @param speakerToken token of the speaker
  * @param token of the atendee
  */
  void subscribeSpeaker(String speakerToken,String token);

  /*
  * Sends a message to every atendee subscribed to the speaker
  * @param message content of the message
  */
  void sendMessageToSubscribers(String message); //aqui usar sendMessage para simplificar

  /*
  * Receives the token current device
  * @return token
  */
  Future<String> getToken();
}