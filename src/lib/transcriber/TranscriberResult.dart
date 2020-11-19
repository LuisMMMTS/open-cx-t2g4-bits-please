class TranscriberResult {
  String _value;
  bool _final;
  TranscriberResult(String value, bool finalResult){
    this._value = value;
    this._final = finalResult;
  }
  bool isFinal(){ return _final; }
  String getValue(){ return _value; }
}
