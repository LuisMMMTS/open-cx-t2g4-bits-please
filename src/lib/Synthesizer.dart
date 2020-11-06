abstract class Synthesizer {
  Future<List<dynamic>> getLanguages();
  void setLanguage(String language);
  String getLanguage();
  void startSynthesizer(String text);
  void stopSynthesizer();
  bool isPlaying();
}
