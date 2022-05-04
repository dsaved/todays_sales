import 'dart:ui';

import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/widgets/Dialogs.dart';
import 'package:todays_sales/widgets/toast.dart';

class AgentManager extends StatefulWidget {
  const AgentManager({Key key, this.agent, this.store, @required this.completed})
      : super(key: key);

  final Map<String, dynamic> agent;
  final Map<String, dynamic> store;
  final VoidCallback completed;

  @override
  _AgentManagerState createState() => _AgentManagerState();
}

class _AgentManagerState extends State<AgentManager> {
  SharedPreferences prefs;
  Map<String, dynamic> agent;
  List<dynamic> auth_options = [];
  double opacity3 = 0.0;
  String type = "Create",
      loading_status = "Creating",
      success_status = "Created",
      status,
      id,
      link = Constant.addAgents;

  TextEditingController _nameController, _phoneController, _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    initAll();
  }

  void initAll() async {
    prefs = await SharedPreferences.getInstance();

    agent = widget.agent;
    if (agent != null && agent.isNotEmpty) {
      link = Constant.updateAgents;
      type = "Update";
      loading_status = "Updating";
      success_status = "Updated";
      id = "${agent['id']}";
      status = agent['active'] == 0 ? 'Inactive' : 'Active';

      _nameController.text = "${agent['name']}";
      _phoneController.text = "${agent['phone']}";
    }

    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity3 = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          "$type agent",
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${LocalText.of(context).load('fullname_hint')}',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextField(
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${LocalText.of(context).load('phone_hint')}',
                  ),
                ),
              ),
              if(type!="Update")Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${LocalText.of(context).load('password_hint')}',
                  ),
                    obscureText: true,
                    obscuringCharacter: '#',
                ),
              ),
              DropdownButton<String>(
                underline: Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.black.withOpacity(0.3)),
                itemHeight: 70,
                hint: Text("Status"),
                value: status,
                isExpanded: true,
                icon: Icon(
                  Icons.error,
                  color: Colors.grey.withOpacity(0.8),
                ),
                items: <String>['Active', 'Inactive'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(
                      value,
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
                onChanged: (_) {
                  status = _;
                  setState(() {});
                },
              ),
              Expanded(child: Container()),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: opacity3,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_nameController.text.isEmpty) {
                              return showToast('${LocalText.of(context).load('name_required')}');
                            }
                            if (_phoneController.text.isEmpty) {
                              return showToast('${LocalText.of(context).load('phone_required')}');
                            }
                            if (type!="Update" && _passwordController.text.isEmpty) {
                              return showToast('${LocalText.of(context).load('password_required')}');
                            }
                            if (status == null || status.isEmpty) {
                              return showToast("Please Select Status");
                            }
                            Map<String, dynamic> _agent = new Map();
                            _agent['id'] = id;
                            _agent['name'] = _nameController.text;
                            _agent['phone'] = _phoneController.text;
                            _agent['store_code'] = widget.store['store_code'];
                            _agent['store_name'] = widget.store['store_name'];
                            if(type!="Update") {
                              _agent['password'] = _passwordController.text;
                            }
                            _agent['active'] = status == 'Inactive' ? 0 : 1;
                            addAgent(_agent);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.pinkMaterial,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(16.0),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: AppColors.pinkMaterial
                                        .withOpacity(0.8),
                                    offset: const Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Center(
                              child: Text('$type',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21
                                  )),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showToast(text) {
    MyToast.showToast(context,text);
  }

  void addAgent(Map<String, dynamic> agent) async {
    NetworkUtil _netUtil = new NetworkUtil();
    Dialogs dialogs = new Dialogs();
    dialogs.loading(
        context, "$loading_status agent, Please wait", Dialogs.GLOWING);
    await _netUtil.post("$link", context, body: agent).then((value) async {
      dialogs.close(context);
      if (value['success'] == true) {
        await dialogs.infoDialog(context, "Completed",
            "The agent has been $success_status successfully",
            onPressed: (pressed) {
          if (pressed) {
            widget.completed();
            Navigator.of(context).pop();
          }
        });
      } else {
        showToast(value['message']);
      }
    }).catchError((error) {
      dialogs.close(context);
      showToast("An Error Occurred");
      print("Error $error");
    });
  }
}
