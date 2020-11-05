import 'package:com_4_all/Synthesizer.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SynthesizerTextToSpeech extends Synthesizer{
  Function stopPlaying;
  FlutterTts flutterTts = new FlutterTts();
  bool isPlayingBool = false;
  String language;
  List<dynamic> languages = null;

  SynthesizerTextToSpeech(Function stopPlaying){
    this.stopPlaying = stopPlaying;

    flutterTts.setCompletionHandler(() {
      stopSynthesizer();
    });

    flutterTts.setErrorHandler((msg) {
      stopSynthesizer();
    });

    flutterTts.setCancelHandler(() {
      stopSynthesizer();
    });
  }

  Future setupLanguages() async{
    languages = await flutterTts.getLanguages;
    languages.sort((a,b){return a.toString().compareTo(b.toString());});
    language = languages.first.toString();
    if(await flutterTts.isLanguageAvailable("pt-PT")) {
      language = "pt-PT";
    }
    flutterTts.setLanguage(language);
  }

  @override
  Future<List<dynamic>> getLanguages() async{
    if(languages==null)
      await setupLanguages();
    return languages;
  }

  @override
  String getLanguage() {
    return language;
  }

  @override
  bool isPlaying() {
    return isPlayingBool;
  }

  @override
  Future setLanguage(String language) async{
    this.language = language;
    await flutterTts.setLanguage(language);
  }

  @override
  Future startSynthesizer(String text) async{
    isPlayingBool = true;
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.7);
    await flutterTts.setPitch(1.0);
    flutterTts.speak(text);
  }

  @override
  Future stopSynthesizer() async{
    await flutterTts.stop();
    isPlayingBool = false;
    stopPlaying();
  }
}