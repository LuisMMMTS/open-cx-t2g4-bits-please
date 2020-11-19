import 'package:com_4_all/transcriber/TranscriberResult.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

typedef TranscriberBeginListener = void Function();
typedef TranscriberEndListener = void Function();
typedef TranscriberErrorListener = void Function(SpeechRecognitionError error);

typedef TranscriberResultListener = void Function(TranscriberResult transcriberResult);
typedef TranscriberSoundLevelListener = void Function(double level);

abstract class Transcriber {
  void initialize({
    TranscriberBeginListener onBegin,
    TranscriberResultListener onResult,
    TranscriberSoundLevelListener onSoundLevel,
    TranscriberEndListener onEnd,
    TranscriberErrorListener onError
  });
  Future<List<LocaleName>> getLocales();
  Future<LocaleName> getSystemLocale();
  void setLocale(String locale);
  String getLocale();
  Future<bool> initSpeech();
  bool isListening;
  void startListening();
  void stopListening();
}
