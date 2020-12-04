import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool darkMode = false;

TextStyle buttonTextStyle(){return TextStyle(color: darkMode ? Color.fromRGBO(0x6f, 0x6f, 0x6f, 1): Colors.black);}
TextStyle blackWhiteTextStyle(){return TextStyle(color: (darkMode ? Color.fromARGB(255, 0, 0, 0) : Colors.white10));}
TextStyle whiteBlackTextStyle(){return TextStyle(color: (darkMode ? Color.fromARGB(255, 255, 255, 255) : Colors.black87));}
Color buttonColor(){return (darkMode ? Color.fromARGB(255, 0x32, 0x32, 0x32) : Colors.blue);}
Color backgroundColor(){return (darkMode ? Color.fromARGB(255, 0, 0, 0) : Colors.white24);}
Color backgroundInverseColor(){return ((darkMode) ? Color.fromARGB(255, 255, 255, 255) : Colors.black87);}




