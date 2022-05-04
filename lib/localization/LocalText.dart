import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalText {
  LocalText(this.locale);

  final Locale locale;

  static LocalText of(BuildContext context) {
    return Localizations.of<LocalText>(context, LocalText);
  }

  Map<String, String> _sentences;

  Future<bool> init() async {
    String data = await rootBundle
        .loadString('assets/lang/${this.locale.languageCode}.json');
    Map<String, dynamic> _result = json.decode(data);

    this._sentences = new Map();
    _result.forEach((String key, dynamic value) {
      this._sentences[key] = value.toString();
    });

    return true;
  }

  String load(String key) {
     String text =  this._sentences[key];
     if(text==null || text.isEmpty){
       text = key;
     }
    return text;
  }

  Widget show(String key, {TextStyle style}) {
    return new Text(
      this._sentences[key],
      style: style,
    );
  }
}
