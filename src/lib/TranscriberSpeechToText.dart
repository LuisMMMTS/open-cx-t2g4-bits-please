
import 'package:speech_to_text/speech_to_text.dart';

import 'Transcriber.dart';

class TranscriberSpeechToText extends Transcriber{
  bool _hasSpeech = false;
  SpeechToText transcriber = SpeechToText();
  TranscriberSpeechToText();

  Future<bool> initialize({SpeechErrorListener onError, SpeechStatusListener onStatus}) async {
    if(!_hasSpeech) {
      _hasSpeech = await transcriber.initialize(
          onError: onError,
          onStatus: onStatus
      );
    }
    return _hasSpeech;
  }

  Future<List<LocaleName>> locales() { return transcriber.locales(); }

  Future<LocaleName> systemLocale() { return transcriber.systemLocale(); }

  bool get isListening => transcriber.isListening;

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
  }){
    return transcriber.listen(
        onResult: onResult,
        listenFor: listenFor,
        pauseFor: pauseFor,
        localeId: localeId,
        onSoundLevelChange: onSoundLevelChange,
        cancelOnError: cancelOnError,
        partialResults: partialResults,
        onDevice: onDevice,
        listenMode: listenMode,
        sampleRate: sampleRate
    );
  }

  Future<void> stop(){
    return transcriber.stop();
  }
}
