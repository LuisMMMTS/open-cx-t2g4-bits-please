abstract class Database {
  void addToken(String speaker_name, String token);

  Future<String> getToken(String speaker_name);

  void removeToken(String speaker_name);
}