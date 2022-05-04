import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/network/rest_ds.dart';
import 'package:todays_sales/resources/theme.dart' as appTheme;
import 'package:todays_sales/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_indicators/progress_indicators.dart';

class RecoverPage extends StatefulWidget {
  static const String tag = "recover-page";

  @override
  State<StatefulWidget> createState() => RecoverPageState();
}

class RecoverPageState extends State<RecoverPage> {
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String phone;

  _backToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    void _validateForms() {
      final form = _formKey.currentState;
      form.save();

      if (phone.isEmpty) {
        MyToast.showToast(context,LocalText.of(context).load('phone_required'));
      } else if (!phone.startsWith("0") || phone.length < 10) {
        MyToast.showToast(context,LocalText.of(context).load('wrong_phone'));
      } else {
        // Every of the data in the form are valid at this point
        setState(() => _isLoading = true);
        RestDatasource request = new RestDatasource();
        request.recover(phone, context).then((Map response) {
          if (response["success"]) {
            onRecoverSuccess(response["message"]);
          } else {
            onRecoverError(response["message"]);
          }
        });
      }
    }

    final logoImage = Container(
      child: Column(
        children: <Widget>[
          Text(
            LocalText.of(context).load('recover_title'),
            style: TextStyle(
                color: Colors.white,
                fontSize: 27.00,
                fontWeight: FontWeight.w700),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 15.00),
          ),
        ],
      ),
    );

    final backgroundImage = Container(
        decoration: BoxDecoration(color: appTheme.AppColors.indigoMaterial));

    final phoneField = Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0)),
        child: TextFormField(
          textInputAction: TextInputAction.done,
          autofocus: false,
          onSaved: (String value) {
            phone = value;
          },
          onFieldSubmitted: (_) => _validateForms(),
          decoration: InputDecoration(
              hintText: LocalText.of(context).load('phone_hint'),
              hintStyle: TextStyle(
                color: Colors.black,
              ),
              contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
              prefixIcon: Icon(
                Icons.phone,
                color: appTheme.AppColors.pink[500],
              ),
              border: InputBorder.none),
          style: TextStyle(
            color: Colors.black,
          ),
          keyboardType: TextInputType.phone,
        ));

    final backToLoginButton = Expanded(
      child: MaterialButton(
        onPressed: () {
          _backToLogin();
        },
        textColor: Colors.white,
        child: Text(LocalText.of(context).load('back_to_login')),
      ),
    );

    final recoverButton = Expanded(
        child: MaterialButton(
      onPressed: _validateForms,
      color: appTheme.AppColors.pinkMaterial[700],
      textColor: Colors.white,
      child: _isLoading
          ? CollectionScaleTransition(
              children: <Widget>[
                Icon(Icons.keyboard_arrow_right),
                Icon(Icons.keyboard_arrow_right),
                Icon(Icons.keyboard_arrow_right),
              ],
            )
          : Text(LocalText.of(context).load('recover')),
      splashColor: appTheme.AppColors.pinkMaterial[300],
    ));

    var pageContent = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 420.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Theme(
                          data: ThemeData(
                              brightness: Brightness.dark,
                              primarySwatch: appTheme.AppColors.indigoMaterial,
                              inputDecorationTheme: InputDecorationTheme(
                                  labelStyle: TextStyle(
                                      color: appTheme
                                          .AppColors.indigoMaterial[500]))),
                          child: Container(
                            padding:
                                const EdgeInsets.only(left: 35.0, right: 35.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                logoImage,
                                phoneField,
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      backToLoginButton,
                                      recoverButton,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: appTheme.AppColors.indigoMaterial,
      body: SafeArea(child: Stack(
        fit: StackFit.expand,
        children: <Widget>[backgroundImage, pageContent],
      )),
    );
  }

  onRecoverError(String errorTxt) {
    MyToast.showToast(context,errorTxt);
    setState(() => _isLoading = false);
  }

  onRecoverSuccess(String successText) {
    MyToast.showToast(context,successText);
    setState(() => _isLoading = false);
    _backToLogin();
  }
}
