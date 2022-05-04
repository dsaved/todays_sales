import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/user.dart';
import 'package:todays_sales/network/rest_ds.dart';
import 'package:todays_sales/pages/home.dart';
import 'package:todays_sales/resources/Countdown.dart';
import 'package:todays_sales/resources/theme.dart' as appTheme;
import 'package:todays_sales/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_indicators/progress_indicators.dart';

class OTPPage extends StatefulWidget {
  static const String tag = "verify-page";

  OTPPage({Key key, @required this.phone});

  final String phone;

  @override
  State<StatefulWidget> createState() => OTPPageState();
}

class OTPPageState extends State<OTPPage> with TickerProviderStateMixin {
  AnimationController _controller;
  bool countingDown = false;
  double animationPos = 0.0;
  bool _isLoading = false, _isLoadingRetry = false, showRetryButton = false;
  static const int timeValue = 120;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String otp;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: timeValue),
    );

    _startCountDown();
    _controller.addListener(() {
      setState(() {
        animationPos = _controller.value;
      });
      if (_controller.isCompleted) {
        countingDown = false;
        animationPos = 0.0;
        showRetryButton = true;
        setState(() {});
      }
    });
  }

  _startCountDown() {
    if (!countingDown) {
      _controller.forward(from: animationPos);
      countingDown = true;
    }
  }

  _stopCountDown() {
    if (countingDown) {
      _controller.stop(canceled: false);
      countingDown = false;
    }
  }

  @override
  dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _validateForms() {
      final form = _formKey.currentState;
      form.save();

      if (otp.isEmpty) {
        MyToast.showToast(context,LocalText.of(context).load('otp_required'));
      } else if (otp.length < 6) {
        MyToast.showToast(context,LocalText.of(context).load('wrong_otp'));
      } else {
        // Every of the data in the form are valid at this point
        setState(() => _isLoading = true);
        RestDatasource request = new RestDatasource();
        request.verifyPhone(widget.phone, otp, context).then((Map response) {
          if (response["success"]) {
            MyToast.showToast(context,response['message']);
            onVerifySuccess(response["user"]);
          } else {
            onVerifyError(response["message"]);
          }
        });
      }
    }

    void _resendCode() {
        setState(() => _isLoadingRetry = true);
        RestDatasource request = new RestDatasource();
        request.resendCode(widget.phone, context).then((Map response) {
          setState(() => _isLoadingRetry = false);
          if (response["success"]) {
            MyToast.showToast(context,"OTP sent successfully");
            _startCountDown();
            showRetryButton = false;
            setState(() {});
          }else{
            MyToast.showToast(context,response['message']);
          }
        });
    }

    final logoImage = Container(
      child: Column(
        children: <Widget>[
          Text(
            LocalText.of(context).load('verify_otp'),
            style: TextStyle(
                color: Colors.white,
                fontSize: 27.00,
                fontWeight: FontWeight.w700),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 5.00),
          ),
          Text(
            LocalText.of(context).load('verify_otp_info'),
            style: TextStyle(
                color: Colors.white,
                fontSize: 13.00,
                fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 15.00),
          ),
        ],
      ),
    );

    final backgroundImage = Container(
        decoration: BoxDecoration(color: appTheme.AppColors.indigoMaterial));

    final otpField = Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0)),
        child: TextFormField(
          textInputAction: TextInputAction.done,
          autofocus: false,
          onSaved: (String value) {
            otp = value;
          },
          onFieldSubmitted: (_) => _validateForms(),
          decoration: InputDecoration(
              hintText: LocalText.of(context).load('otp_hint'),
              hintStyle: TextStyle(
                color: Colors.black,
              ),
              contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
              prefixIcon: Icon(
                Icons.password,
                color: appTheme.AppColors.pink[500],
              ),
              border: InputBorder.none),
          style: TextStyle(
            color: Colors.black,
          ),
          keyboardType: TextInputType.number,
        ));

    final verifyButton = MaterialButton(
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
          : Text(LocalText.of(context).load('verify')),
      splashColor: appTheme.AppColors.pinkMaterial[300],
    );

    final resendCodeButton = MaterialButton(
      onPressed: _resendCode,
      color: appTheme.AppColors.greyMaterial[700],
      textColor: Colors.white,
      child: _isLoadingRetry
          ? SpinKitRipple(
              color: Colors.white,
              size: 25,
            )
          : Text(LocalText.of(context).load('resend') ?? "retry"),
      splashColor: appTheme.AppColors.pinkMaterial[300],
    );

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
                                otpField,
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      showRetryButton == false
                                          ? Row(
                                              children: [
                                                Text(
                                                  LocalText.of(context)
                                                      .load('retry_in'),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13.00,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Countdown(
                                                  animation: new StepTween(
                                                    begin: timeValue,
                                                    end: 0,
                                                  ).animate(_controller),
                                                )
                                              ],
                                            )
                                          : resendCodeButton,
                                      verifyButton,
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
      body: SafeArea(
          child: Stack(
        fit: StackFit.expand,
        children: <Widget>[backgroundImage, pageContent],
      )),
    );
  }

  onVerifyError(String errorTxt) {
    MyToast.showToast(context,errorTxt);
    setState(() => _isLoading = false);
  }

  onVerifySuccess(User user) async {
    setState(() => _isLoading = false);
    var db = new DatabaseHelper();
    await db.saveUser(user);
    var userData = await db.getUser();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            data: userData,
          ),
        ));
  }
}
