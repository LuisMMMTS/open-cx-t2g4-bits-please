import 'package:speech_to_text/speech_to_text.dart';

abstract class Transcriber {
  Future<List<LocaleName>> getLocales();
  Future<LocaleName> getSystemLocale();
  void setLocale(String locale);
  String getLocale();
  Future<bool> initSpeech();
  bool isListening;
  void startListening();
  void stopListening();
}
