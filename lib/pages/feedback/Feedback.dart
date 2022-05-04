import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/utils/rating_bar.dart';
import 'package:todays_sales/widgets/Dialogs.dart';
import 'package:todays_sales/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Feedbacks extends StatefulWidget {
  static const String tag = "news-page";

  Feedbacks({@required this.user});

  Map<String, dynamic> user;

  @override
  _NewsPageState createState() => new _NewsPageState();
}

class _NewsPageState extends State<Feedbacks> {
  String _rating;
  TextEditingController _textController;
  double initialRating = 0;
  NetworkUtil _netUtil = new NetworkUtil();
  Dialogs _dialogs = new Dialogs();
  UniqueKey _uniqueKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController();
  }

  @override
  dispose() {
    _textController.dispose();
    super.dispose();
  }

  _validateForms() {
    if (_textController.text.isEmpty) {
      MyToast.showToast(context,LocalText.of(context).load("rate_message"));
    } else if (null == _rating || _rating.isEmpty) {
      MyToast.showToast(context,LocalText.of(context).load("rating_required"));
    } else {
      _dialogs.loading(
          context,
          "${LocalText.of(context).load('sending_feedback')}",
          Dialogs.SCALE_TRANSITION);
      String message = _textController.text +
          ".\nWith a rating of: $_rating\nFrom ${widget.user['name']} <${widget.user['phone']}> ";
      Map<String, dynamic> params = new Map();
      params["phone"] = widget.user['phone'];
      params["message"] = message;
      params["name"] = widget.user['name'];

      _netUtil
          .post(Constant.feedback, context, body: params)
          .then((dynamic value) {
            _dialogs.close(context);
            if (value['success'] == true) {
              MyToast.showToast(context,
                  "${LocalText.of(context).load("message_sent")}");
              setState(() {
                _textController.text = "";
                initialRating = 0;
                _rating = "";
                _uniqueKey = UniqueKey();
              });
            } else {
              MyToast.showToast(context,
                  "${LocalText.of(context).load("could_not_send_message")}");
            }
          })
          .timeout(Duration(seconds: 10))
          .catchError((error) {
            _dialogs.close(context);
            print("Error $error");
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LocalText.of(context).show("send_us_message",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.7))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LocalText.of(context).show("feedback_note",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.5))),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 10),
                child: Text("${widget.user['name']}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.7))),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 20),
                child: Text("${widget.user['phone']}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.7))),
              ),
              CupertinoTextField(
                padding: EdgeInsets.only(
                    top: 20.0, bottom: 20.0, left: 10.0, right: 10.0),
                controller: _textController,
                autofocus: false,
                maxLines: 5,
                keyboardType: TextInputType.text,
                placeholder: LocalText.of(context).load("your_message"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LocalText.of(context).show("rate_me",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.6))),
              ),
              Container(
                key: _uniqueKey,
                child: RatingBar(
                  initialRating: initialRating,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  glowRadius: 1,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _int) {
                    Icon icon;
                    switch (_int) {
                      case 0:
                        icon = Icon(
                          Icons.sentiment_very_dissatisfied,
                          color: Colors.red,
                        );
                        break;
                      case 1:
                        icon = Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.redAccent,
                        );
                        break;
                      case 2:
                        icon = Icon(
                          Icons.sentiment_neutral,
                          color: Colors.amber,
                        );
                        break;
                      case 3:
                        icon = Icon(
                          Icons.sentiment_satisfied,
                          color: Colors.lightGreen,
                        );
                        break;
                      case 4:
                        icon = Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.green,
                        );
                        break;
                    }
                    return icon;
                  },
                  onRatingUpdate: (rating) {
                    String ratingBarStringValue = "";
                    if (rating > 0 && rating <= 2) {
                      ratingBarStringValue = "$rating Poor";
                    } else if (rating > 2 && rating <= 3) {
                      ratingBarStringValue = "$rating It's Ok";
                    } else if (rating > 3 && rating < 4.1) {
                      ratingBarStringValue = "$rating Good";
                    } else if (rating > 4 && rating < 6) {
                      ratingBarStringValue = "$rating Excellent";
                    }
                    setState(() {
                      _rating = ratingBarStringValue;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 15, top: 8),
                child: null != _rating
                    ? Text("$_rating",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(.5)))
                    : Container(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: CupertinoButton(
                  color: AppColors.pinkMaterial[400],
                  onPressed: _validateForms,
                  pressedOpacity: 0.7,
                  child: Text(LocalText.of(context).load("submit")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
