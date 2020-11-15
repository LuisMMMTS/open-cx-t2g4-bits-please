typedef void VoidCallback(String);

abstract class Messaging{
  void sendMessage(String token,String message);
  void subscribeSpeaker(String speakerToken,String token);
  void sendMessageToSubscribers(String message);
  Future<String> getToken();
}