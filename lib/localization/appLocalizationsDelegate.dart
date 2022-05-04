import 'dart:async';

import 'package:todays_sales/localization/LocalText.dart';
import 'package:flutter/material.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<LocalText> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['pt', 'en'].contains(locale.languageCode);

  @override
  Future<LocalText> load(Locale locale) async {
    LocalText localizations = new LocalText(locale);
    await localizations.init();

    print("Load ${locale.languageCode}");

    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
