import 'package:flutter/cupertino.dart';
import 'package:toast/toast.dart';

class MyToast {
  static void showToast(
    BuildContext context,
    String msg,
  ) {
    try {
      Toast.show('$msg', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } on Exception catch (Ex) {
      print(Ex);
    }
  }
}
