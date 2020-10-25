import 'package:speech_to_text/speech_to_text.dart';

abstract class Transcriber {
  Future<List<LocaleName>> locales();
  Future<LocaleName> systemLocale();
  Future<bool> initialize({SpeechErrorListener onError, SpeechStatusListener onStatus});
  bool isListening;
  Future<dynamic> listen({
    SpeechResultListener onResult,
    Duration listenFor,
    Duration pauseFor,
    String localeId,
    SpeechSoundLevelChange onSoundLevelChange,
    dynamic cancelOnError: false,
    dynamic partialResults: true,
    dynamic onDevice: false,
    ListenMode listenMode: ListenMode.confirmation,
    dynamic sampleRate: 0
  });
  Future<void> stop();
}
