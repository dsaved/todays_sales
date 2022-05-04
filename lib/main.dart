import 'package:todays_sales/localization/appLocalizationsDelegate.dart';
import 'package:todays_sales/pages/DispatchPage.dart';
import 'package:todays_sales/pages/home.dart';
import 'package:todays_sales/pages/login/login.dart';
import 'package:todays_sales/pages/recover/recover.dart';
import 'package:todays_sales/pages/register/register.dart';
import 'package:todays_sales/resources/routes.dart';
import 'package:todays_sales/resources/theme.dart' as Theme;
import 'package:todays_sales/utils/custormrouter.dart';
import 'package:flutter/material.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new Application());
}

class Application extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //router pages config with animation
    // ignore: missing_return
    final appRoutes = (RouteSettings settings) {
      switch (settings.name) {
        case LoginPage.tag:
          return MyCustomRoute(
            builder: (_) => new LoginPage(),
            settings: settings,
          );
        case RegisterPage.tag:
          return MyCustomRoute(
            builder: (_) => new RegisterPage(),
            settings: settings,
          );
        case MyHomePage.tag:
          return MyCustomRoute(
            builder: (_) => new MyHomePage(),
            settings: settings,
          );
        case RecoverPage.tag:
          return MyCustomRoute(
            builder: (_) => new RecoverPage(),
            settings: settings,
          );
      }
      assert(false);
    };

    return new MaterialApp(
      supportedLocales: [const Locale('pt', 'PT-PT'), const Locale('en', 'US')],
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        if (locale == null) {
          return supportedLocales.first;
        }

        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode ||
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }

        return supportedLocales.first;
      },
      color: Theme.AppColors.indigo[500],
      onGenerateRoute: appRoutes,
      routes: routes,
      debugShowCheckedModeBanner: false,
      theme: Theme.appThemeData,
      home: DispatchPage(),
    );
  }
}
