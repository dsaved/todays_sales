import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:todays_sales/resources/theme.dart';

typedef void AcceptCallBack(bool success);
typedef void CreditCashCallback(int creditorCash);
typedef void TextCallBack(String text);

class CreditCash {
  static const CREDIT = 1;
  static const CASH = 0;
}

class Dialogs {
  static const SCALE_TRANSITION = 1,
      SLIDE_TRANSITION = 2,
      GLOWING = 3,
      TEXT_JUMPING = 4,
      TEXT_FADING = 5,
      TEXT_SLIDING = 6;

  bool _isLoading = false;

  infoDialog(BuildContext context, String mTitle, String description,
      {AcceptCallBack onPressed}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[100],
            title: Text(
              mTitle,
              style:
                  TextStyle(color: Colors.black26, fontWeight: FontWeight.bold),
            ),
            content: Container(
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(description, style: TextStyle(color: Colors.black))
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPressed(true);
                },
                child: Text(
                  'Okay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        });
  }

  loading(BuildContext context, String mTitle, int loader) {
    Widget loadContent;
    switch (loader) {
      case SCALE_TRANSITION:
        loadContent = CollectionScaleTransition(
          children: <Widget>[
            Icon(Icons.keyboard_arrow_right),
            Icon(Icons.keyboard_arrow_right),
            Icon(Icons.keyboard_arrow_right),
          ],
        );
        break;
      case SLIDE_TRANSITION:
        loadContent = CollectionSlideTransition(
          children: <Widget>[
            Icon(Icons.apps),
            Icon(Icons.apps),
            Icon(Icons.apps),
          ],
        );
        break;
      case GLOWING:
        loadContent = GlowingProgressIndicator(
          child: Icon(Icons.radio_button_checked),
        );
        break;
      case TEXT_JUMPING:
        loadContent = JumpingText(LocalText.of(context).load("please_wait"));
        break;
      case TEXT_FADING:
        loadContent = FadingText(LocalText.of(context).load("please_wait"));
        break;
      case TEXT_SLIDING:
        loadContent = ScalingText(LocalText.of(context).load("please_wait"));
        break;
      default:
        loadContent = CollectionScaleTransition(
          children: <Widget>[
            Icon(Icons.keyboard_arrow_right),
            Icon(Icons.keyboard_arrow_right),
            Icon(Icons.keyboard_arrow_right),
          ],
        );
        break;
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          this._isLoading = true;
          return AlertDialog(
              title: Text(mTitle),
              content: SingleChildScrollView(
                child: Center(
                  child: ListBody(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          loadContent,
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  close(BuildContext context) {
    if (this._isLoading) {
      this._isLoading = false;
      Navigator.pop(context);
    }
  }

  Future<void> cashCreditDialog(BuildContext context,
      {CreditCashCallback onPressed}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Is this sale going on credit or cash?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          onPressed(CreditCash.CREDIT);
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.credit_score_sharp,
                              size: 100,
                              color: AppColors.pinkMaterial[700],
                            ),
                            Text('CREDIT',style: TextStyle(color: AppColors.pinkMaterial[700]),)
                          ],
                        )
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          onPressed(CreditCash.CASH);
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.money_rounded,
                              size: 100,
                              color: AppColors.tealMaterial[700],
                            ),
                            Text('CASH',style: TextStyle(color: AppColors.tealMaterial[700]),)
                          ],
                        )),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  confirm(BuildContext context, String mTitle, String description,
      {AcceptCallBack onPressed}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(mTitle),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(description)],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPressed(false);
                },
                child: Text(
                  LocalText.of(context).load("cancel_text"),
                  style: TextStyle(color: AppColors.greyMaterial[700]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPressed(true);
                },
                child: Text(LocalText.of(context).load("ok_text")),
              ),
            ],
          );
        });
  }

  inputDialog(BuildContext context, String mTitle,
      {TextCallBack onPressed, @required TextInputType keyboardType}) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _textInputController = TextEditingController();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(mTitle),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: TextFormField(
                      controller: _textInputController,
                      decoration: InputDecoration(
                        labelText: mTitle,
                        icon: Icon(Icons.dynamic_feed),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please $mTitle';
                        }
                        return null;
                      },
                      keyboardType: keyboardType,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPressed(null);
                },
                child: Text(
                  LocalText.of(context).load("cancel_text"),
                  style: TextStyle(color: AppColors.greyMaterial[700]),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Navigator.pop(context);
                    onPressed(_textInputController.text);
                  }
                },
                child: Text(LocalText.of(context).load("ok_text")),
              ),
            ],
          );
        });
  }

  progress(
      BuildContext context, String mTitle, String progressText, double progress,
      {AcceptCallBack onPressed}) {
    print("current progress: $progress");
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        if (progress >= 1.0) {
          Navigator.of(context).pop();
        }

        return AlertDialog(
          title: new Text(
            mTitle,
            style: TextStyle(fontSize: 14.0),
          ),
          content: Padding(
            padding: EdgeInsets.all(8.0),
            child: new LinearPercentIndicator(
              width: 180.0,
              lineHeight: 14.0,
              percent: progress,
              center: Text(
                "$progressText",
                style: new TextStyle(fontSize: 12.0),
              ),
              trailing: Icon(Icons.music_note),
              linearStrokeCap: LinearStrokeCap.roundAll,
              backgroundColor: Colors.grey,
              progressColor: Colors.blue,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: LocalText.of(context).show(
                'cancel_text',
                style: TextStyle(color: AppColors.greyMaterial[700]),
              ),
              onPressed: () {
                onPressed(true);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
