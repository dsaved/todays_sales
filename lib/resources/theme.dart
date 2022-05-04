import 'package:flutter/material.dart';

final ThemeData appThemeData = new ThemeData(
    brightness: Brightness.light,
    primarySwatch: AppColors.indigoMaterial,
    primaryColor: AppColors.indigo[500],
    primaryColorBrightness: Brightness.dark,
    accentColor: AppColors.indigo[200],
    accentColorBrightness: Brightness.dark,
    fontFamily: 'Roboto');

final ThemeData videoPlayerTheme = new ThemeData(
    brightness: Brightness.light,
    primarySwatch: AppColors.pinkMaterial,
    primaryColor: AppColors.pink[500],
    primaryColorBrightness: Brightness.dark,
    accentColor: AppColors.pink[200],
    accentColorBrightness: Brightness.dark,
    fontFamily: 'Roboto');

class AppColors {
  AppColors._(); // this basically makes it so you can instantiate this class

  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF2F3F8);
  static const Color nearlyDarkBlue = Color(0xFF2633C5);
  static const Color nearlyDarkGreen = Color(0xFF26C529);
  static const Color nearlyDarkYellow = Color(0xFFC5B526);
  static const Color nearlyDarkRed = Color(0xFFC5262B);

  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color dark_grey = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color spacer = Color(0xFFF2F2F2);

  static const _tealPrimaryValue = 0xFF00796B;
  static const _indigoPrimaryValue = 0xFF26317E;
  static const _orangePrimaryValue = 0xFFFF5722;
  static const _purplePrimaryValue = 0xFF7b1fa2;
  static const _pinkPrimaryValue = 0xFFff005b;
  static const _darkPinkPrimaryValue = 0xFFA01543;
  static const _bluePrimaryValue = 0xFF3f51b5;
  static const _amberPrimaryValue = 0xFFffa000;
  static const _greyPrimaryValue = 0xFF9e9e9e;
  static const backGroundColor = Color(0xFFFFFFFF);
  static const textColor = Color(0xFF02332c);

  static Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.indigo[600];
    }
    return AppColors.indigo[400];
  }

  static Color redColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.pink[600];
    }
    return AppColors.pink[400];
  }

  static const accentColor = Color(0xFFFF5722);
  static const primaryLight = Color(0xFFff8a65);
  static const primaryDark = Color(0xFFFF5722);

  static const Map<int, Color> purple_old = const <int, Color>{
    50: const Color(0xFFf3e5f5),
    100: const Color(0xFFe1bee7),
    200: const Color(0xFFce93d8),
    300: const Color(0xFFba68c8),
    400: const Color(0xFFab47bc),
    500: const Color(0xFF9c27b0),
    600: const Color(0xFF8e24aa),
    700: const Color(_tealPrimaryValue),
    800: const Color(0xFF6a1b9a),
    900: const Color(0xFF4a148c)
  };

  static const MaterialColor purpleMaterial_old =
      MaterialColor(_purplePrimaryValue, <int, Color>{
    50: const Color(0xFFf3e5f5),
    100: const Color(0xFFe1bee7),
    200: const Color(0xFFce93d8),
    300: const Color(0xFFba68c8),
    400: const Color(0xFFab47bc),
    500: const Color(0xFF9c27b0),
    600: const Color(0xFF8e24aa),
    700: const Color(_purplePrimaryValue),
    800: const Color(0xFF6a1b9a),
    900: const Color(0xFF4a148c)
  });

  static const Map<int, Color> amber = const <int, Color>{
    50: const Color(0xFFfff8e1),
    100: const Color(0xFFffecb3),
    200: const Color(0xFFffe082),
    300: const Color(0xFFffd54f),
    400: const Color(0xFFffca28),
    500: const Color(0xFFffc107),
    600: const Color(0xFFffb300),
    700: const Color(_amberPrimaryValue),
    800: const Color(0xFFff8f00),
    900: const Color(0xFFff6f00)
  };

  static const MaterialColor amberMaterial =
      MaterialColor(_amberPrimaryValue, <int, Color>{
    50: const Color(0xFFfff8e1),
    100: const Color(0xFFffecb3),
    200: const Color(0xFFffe082),
    300: const Color(0xFFffd54f),
    400: const Color(0xFFffca28),
    500: const Color(0xFFffc107),
    600: const Color(0xFFffb300),
    700: const Color(_amberPrimaryValue),
    800: const Color(0xFFff8f00),
    900: const Color(0xFFff6f00)
  });

  static const Map<int, Color> teal = const <int, Color>{
    50: const Color(0xFFe0f2f1),
    100: const Color(0xFFb2dfdb),
    200: const Color(0xFF80cbc4),
    300: const Color(0xFF4db6ac),
    400: const Color(0xFF26a69a),
    500: const Color(0xFF009688),
    600: const Color(0xFF00897b),
    700: const Color(_tealPrimaryValue),
    800: const Color(0xFF00695c),
    900: const Color(0xFF004d40)
  };

  static const MaterialColor tealMaterial =
      MaterialColor(_tealPrimaryValue, <int, Color>{
    50: const Color(0xFFe0f2f1),
    100: const Color(0xFFb2dfdb),
    200: const Color(0xFF80cbc4),
    300: const Color(0xFF4db6ac),
    400: const Color(0xFF26a69a),
    500: const Color(0xFF009688),
    600: const Color(0xFF00897b),
    700: const Color(_tealPrimaryValue),
    800: const Color(0xFF00695c),
    900: const Color(0xFF004d40)
  });

  static const Map<int, Color> indigo = const <int, Color>{
    50: const Color(0xFF626FD0),
    100: const Color(0xFF5260CB),
    200: const Color(0xFF4352C7),
    300: const Color(0xFF3848BC),
    400: const Color(0xFF3442AD),
    500: const Color(0xFF2F3C9D),
    600: const Color(0xFF2A368D),
    700: const Color(_indigoPrimaryValue),
    800: const Color(0xFF212B6E),
    900: const Color(0xFF1C255E)
  };

  static const MaterialColor indigoMaterial =
      MaterialColor(_indigoPrimaryValue, <int, Color>{
    50: const Color(0xFF626FD0),
    100: const Color(0xFF5260CB),
    200: const Color(0xFF4352C7),
    300: const Color(0xFF3848BC),
    400: const Color(0xFF3442AD),
    500: const Color(0xFF2F3C9D),
    600: const Color(0xFF2A368D),
    700: const Color(_indigoPrimaryValue),
    800: const Color(0xFF212B6E),
    900: const Color(0xFF1C255E)
  });

  static const MaterialColor orangeMaterial =
  MaterialColor(_orangePrimaryValue, <int, Color>{
    50: const Color(0xFFfbe9e7),
    100: const Color(0xFFffccbc),
    200: const Color(0xFFffab91),
    300: const Color(0xFFff8a65),
    400: const Color(0xFFff7043),
    500: const Color(_orangePrimaryValue),
    600: const Color(0xFFf4511e),
    700: const Color(0xFFe64a19),
    800: const Color(0xFFd84315),
    900: const Color(0xFFbf360c)
  });

  static const Map<int, Color> orange = const <int, Color>{
    50: const Color(0xFFfbe9e7),
    100: const Color(0xFFffccbc),
    200: const Color(0xFFffab91),
    300: const Color(0xFFff8a65),
    400: const Color(0xFFff7043),
    500: const Color(_orangePrimaryValue),
    600: const Color(0xFFf4511e),
    700: const Color(0xFFe64a19),
    800: const Color(0xFFd84315),
    900: const Color(0xFFbf360c)
  };

  static const MaterialColor blueMaterial =
  MaterialColor(_bluePrimaryValue, <int, Color>{
    50: const Color(0xFFe8eaf6),
    100: const Color(0xFF9fa8da),
    200: const Color(0xFF9fa8da),
    300: const Color(0xFF7986cb),
    400: const Color(0xFF5c6bc0),
    500: const Color(_bluePrimaryValue),
    600: const Color(0xFF3949ab),
    700: const Color(0xFF303f9f),
    800: const Color(0xFF283593),
    900: const Color(0xFF1a237e)
  });

  static const Map<int, Color> blue = const <int, Color>{
    50: const Color(0xFFe8eaf6),
    100: const Color(0xFF9fa8da),
    200: const Color(0xFF9fa8da),
    300: const Color(0xFF7986cb),
    400: const Color(0xFF5c6bc0),
    500: const Color(_bluePrimaryValue),
    600: const Color(0xFF3949ab),
    700: const Color(0xFF303f9f),
    800: const Color(0xFF283593),
    900: const Color(0xFF1a237e)
  };

  static const MaterialColor pinkMaterial =
  MaterialColor(_pinkPrimaryValue, <int, Color>{
    50: const Color(0xFFFFD0E1),
    100: const Color(0xFFFF5C96),
    200: const Color(0xFFFF4587),
    300: const Color(0xFFFF2E78),
    400: const Color(0xFFFF1769),
    500: const Color(_pinkPrimaryValue),
    600: const Color(0xFFE80053),
    700: const Color(0xFFD1004B),
    800: const Color(0xFFBA0043),
    900: const Color(0xFFA3003A)
  });

  static const Map<int, Color> pink = const <int, Color>{
    50: const Color(0xFFFFD0E1),
    100: const Color(0xFFFF5C96),
    200: const Color(0xFFFF4587),
    300: const Color(0xFFFF2E78),
    400: const Color(0xFFFF1769),
    500: const Color(_pinkPrimaryValue),
    600: const Color(0xFFE80053),
    700: const Color(0xFFD1004B),
    800: const Color(0xFFBA0043),
    900: const Color(0xFFA3003A)
  };


  static const MaterialColor darkPinkMaterial =
  MaterialColor(_darkPinkPrimaryValue, <int, Color>{
    50: const Color(0xFFC97391),
    100: const Color(0xFFC05C7F),
    200: const Color(0xFFB7456D),
    300: const Color(0xFFAE2E5B),
    400: const Color(0xFFAF1749),
    500: const Color(_darkPinkPrimaryValue),
    600: const Color(0xFF8F0032),
    700: const Color(0xFF81002E),
    800: const Color(0xFF730029),
    900: const Color(0xFF640023)
  });

  static const Map<int, Color> darkPink = const <int, Color>{
    50: const Color(0xFFC97391),
    100: const Color(0xFFC05C7F),
    200: const Color(0xFFB7456D),
    300: const Color(0xFFAE2E5B),
    400: const Color(0xFFAF1749),
    500: const Color(_darkPinkPrimaryValue),
    600: const Color(0xFF8F0032),
    700: const Color(0xFF81002E),
    800: const Color(0xFF730029),
    900: const Color(0xFF640023)
  };
  static const MaterialColor purpleMaterial = blueMaterial;
  static const Map<int, Color>  purple= blue;


  static const MaterialColor greyMaterial =
  MaterialColor(_greyPrimaryValue, <int, Color>{
    50: const Color(0xFFfafafa),
    100: const Color(0xFFf5f5f5),
    200: const Color(0xFFeeeeee),
    300: const Color(0xFFe0e0e0),
    400: const Color(0xFFbdbdbd),
    500: const Color(_greyPrimaryValue),
    600: const Color(0xFF757575),
    700: const Color(0xFF616161),
    800: const Color(0xFF424242),
    900: const Color(0xFF212121)
  });

  static const Map<int, Color> grey = const <int, Color>{
    50: const Color(0xFFfafafa),
    100: const Color(0xFFf5f5f5),
    200: const Color(0xFFeeeeee),
    300: const Color(0xFFe0e0e0),
    400: const Color(0xFFbdbdbd),
    500: const Color(_greyPrimaryValue),
    600: const Color(0xFF757575),
    700: const Color(0xFF616161),
    800: const Color(0xFF424242),
    900: const Color(0xFF212121)
  };
}
