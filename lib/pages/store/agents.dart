import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/pages/store/agent_manager.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AgentsPage extends StatefulWidget {
  const AgentsPage({Key key, @required this.store}) : super(key: key);
  final Map<String, dynamic> store;

  @override
  _AgentsPageState createState() => _AgentsPageState();
}

class _AgentsPageState extends State<AgentsPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<dynamic> agents = [];
  Map<String, dynamic> pagination = Map();
  final ScrollController scrollController = ScrollController();
  int resultPerPage = 20, page = 1;
  TextEditingController _searchInputController;
  NetworkUtil _netUtil = new NetworkUtil();
  SharedPreferences prefs;
  bool socketConnected = false,
      _loading = true,
      _loadingMore = false,
      _showFAB = true,
      searched = false;
  String searchText = "";

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initAll();

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        _showFAB = true;
        if (mounted) {
          setState(() {});
        }
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showFAB = false;
        if (mounted) {
          setState(() {});
        }
      }

      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0) {
          // You're at the top.
          if (!searched) {
            page = 1;
            _getData(silent: true, page: page);
          }
        } else {
          // You're at the bottom.
          if (pagination != null &&
              pagination.isNotEmpty &&
              pagination['hasNext']) {
            page += 1;
            _getData(more: true, silent: true, page: page, search: searchText);
          }
        }
      }
    });
    super.initState();
  }

  initAll() async {
    _searchInputController = new TextEditingController();
    prefs = await SharedPreferences.getInstance();

    String agentsPrefs =
        prefs.getString(Constant.agentsPrefs + widget.store['store_code']);
    if (agentsPrefs != null) {
      _loading = false;
      agents = json.decode(agentsPrefs);
      setState(() {});
      _getData(silent: true);
    } else {
      _getData();
    }
  }

  _getData({more = false, silent = false, page = 1, search = ""}) async {
    if (more) {
      _loadingMore = true;
      setState(() {});
    }
    if (!silent) {
      setState(() {
        _loading = true;
      });
    }

    Map<String, dynamic> params = new Map();
    params["result_per_page"] = resultPerPage;
    params["search"] = search;
    params["store_code"] = widget.store['store_code'];
    params["page"] = page;

    await _netUtil
        .post("${Constant.getAgents}", context, body: params)
        .then((value) {
          setState(() {
            _loading = false;
            _loadingMore = false;
          });
          pagination = value['pagination'];
          if (value['success'] == true) {
            if (more) {
              agents.insertAll(agents.length, value['agents']);
            } else {
              agents = value['agents'];
              prefs.setString(Constant.agentsPrefs + widget.store['store_code'],
                  json.encode(agents));
            }
            _loading = false;
            setState(() {});
          } else {
            _loading = false;
            if (!silent) {
              if (mounted) {
                setState(() {});
              }
            }
          }
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          print("Error $error");
          _loading = false;
          _loadingMore = false;
        });
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    if (mounted) await _getData(silent: true);
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyMaterial[100],
      appBar: new AppBar(
        brightness: Brightness.dark,
        title: Text('${LocalText.of(context).load('agents')}'),
      ),
      body: ListView(
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutGrid(
              areas: '''
                header header header
                search search btn
                content content content
              ''',
              columnSizes: [auto, auto, 50.px],
              rowSizes: [auto, auto, auto],
              columnGap: 12,
              rowGap: 12,
              children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      border: Border.all(
                          width: 1, color: AppColors.greyMaterial[300]),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: TextFormField(
                    autofocus: false,
                    controller: _searchInputController,
                    onSaved: (String value) {},
                    decoration: InputDecoration(
                        hintText: LocalText.of(context).load('agent-search'),
                        contentPadding:
                            EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        border: InputBorder.none),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ).inGridArea('search'),
                TextButton(
                  onPressed: () {
                    String result = _searchInputController.text;
                    if (result != null) {
                      agents = [];
                      page = 1;
                      searched = true;
                      searchText = result;
                      _getData(page: page, search: result);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppColors.greyMaterial[50]),
                    elevation: MaterialStateProperty.all(2.0),
                  ),
                  child: Icon(
                    Icons.search,
                    size: 30,
                    color: AppColors.pinkMaterial,
                  ),
                ).inGridArea('btn'),
                if (searched)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 24, right: 24, top: 0, bottom: 10),
                    child: InkWell(
                      child: Text(
                        '${LocalText.of(context).load('clear-search')}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          letterSpacing: 0.0,
                          color: AppColors.greyMaterial[600],
                        ),
                      ),
                      onTap: () {
                        searched = false;
                        page = 1;
                        searchText = "";
                        _searchInputController.text = "";
                        if (mounted) {
                          setState(() {});
                        }
                        _getData(page: page);
                      },
                    ),
                  ).inGridArea('content')
              ],
            ),
          ),
          if (_loading)
            SpinKitRing(
              lineWidth: 4.0,
              color: AppColors.indigoMaterial,
              size: 30,
            )
          else
            agents != null && agents.length > 0
                ? Column(
                    children: [
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: agents.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            var agent = agents[index];

                            bool inActive = agent['active'] == 0;
                            String status = inActive ? 'Inactive' : 'Active';
                            Color bgColor = inActive
                                ? AppColors.blueMaterial[50]
                                : Colors.white;
                            Color txtColor = inActive
                                ? AppColors.pinkMaterial[600]
                                : Colors.black.withOpacity(.6);

                            return Container(
                              margin: EdgeInsets.only(
                                  left: 6.0, right: 6.0, bottom: 4.0),
                              child: Card(
                                color: bgColor,
                                elevation: 1,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: -50,
                                      bottom: 0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        child: SizedBox(
                                          height: 150,
                                          child: AspectRatio(
                                            aspectRatio: 1.714,
                                            child: Opacity(
                                                opacity: 0.04,
                                                child: Image.asset(
                                                    Constant.card_bottom_left)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      minVerticalPadding: 10.0,
                                      leading: Icon(
                                        Icons.account_circle_rounded,
                                        size: 35,
                                        color: AppColors.pinkMaterial,
                                      ),
                                      title: Text(
                                        '${agent['name']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${agent['phone']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '$status',
                                            style: TextStyle(
                                              color: txtColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: PopupMenuButton(
                                          icon: Icon(Icons.more_vert_sharp),
                                          elevation: 20,
                                          onSelected: (action) {
                                            if (action == 1) {
                                              updateAgent(agent);
                                            } else if (action == 2) {
                                              showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CreateUpdateDialog(
                                                        agent, widget.store,
                                                        completed: () {
                                                      _getData(silent: true);
                                                    });
                                                  });
                                            } else if (action == 2) {
                                              launch('tel://${agent['phone']}');
                                            }
                                          },
                                          itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  child: Text(
                                                    '${LocalText.of(context).load('edit_button')}',
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.9),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  value: 1,
                                                ),
                                                PopupMenuItem(
                                                  child: Text(
                                                    '${LocalText.of(context).load('change_password')}',
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.9),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  value: 2,
                                                ),
                                                PopupMenuItem(
                                                  child: Text(
                                                    '${LocalText.of(context).load('call')}',
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.9),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  value: 3,
                                                )
                                              ]),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_loadingMore)
                        SpinKitRing(
                          lineWidth: 4.0,
                          color: AppColors.indigoMaterial,
                          size: 30,
                        ),
                      SizedBox(height: 15)
                    ],
                  )
                : Center(
                    child: SizedBox(
                      child: Text(
                        '${LocalText.of(context).load('no-agents-available')}',
                        style: TextStyle(
                            color: AppColors.greyMaterial[500],
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
        ],
      ),
      floatingActionButton: _showFAB
          ? FloatingActionButton.extended(
              onPressed: addAgent,
              icon: Icon(Icons.add),
              label: Text('${LocalText.of(context).load('add-agent')}'),
              backgroundColor: AppColors.pinkMaterial,
            )
          : Container(),
    );
  }

  addAgent() {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => AgentManager(
              completed: () {
                _getData(silent: true);
              },
              store: widget.store,
            ));
  }

  updateAgent(Map<String, dynamic> agent) {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => AgentManager(
              agent: agent,
              completed: () {
                _getData(silent: true);
              },
              store: widget.store,
            ));
  }
}

class CreateUpdateDialog extends StatefulWidget {
  CreateUpdateDialog(this.agent, this.store, {@required this.completed});

  final Map<String, dynamic> agent;
  final Map<String, dynamic> store;
  final VoidCallback completed;

  @override
  _MyDialogState createState() => new _MyDialogState();
}

class _MyDialogState extends State<CreateUpdateDialog> {
  bool _creatingStore = false, editing = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController;

  int agentID = 0;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> agentData = widget.agent;
    if (agentData != null && agentData.isNotEmpty) {
      agentID = int.parse('${agentData['id']}');
    }
    editing = agentID != 0;
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  reloadState() {
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: LocalText.of(context).show(
        'change_password',
        style: TextStyle(
            color: AppColors.pinkMaterial,
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: LocalText.of(context).load('password_hint'),
                  icon: Icon(Icons.password_outlined),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return LocalText.of(context).load('password_required');
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          child: LocalText.of(context).show('cancel_text',
              style: TextStyle(color: AppColors.greyMaterial[700])),
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(AppColors.greyMaterial[200])),
        ),
        ElevatedButton(
            child: _creatingStore
                ? SizedBox(
                    width: 35,
                    child: SpinKitRing(
                      lineWidth: 2.0,
                      color: AppColors.greyMaterial[50],
                      size: 15,
                    ),
                  )
                : editing
                    ? LocalText.of(context).show('update')
                    : LocalText.of(context).show('create'),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _creatingStore = true;
                reloadState();
                if (editing) {
                  updateStore();
                }
              }
            })
      ],
    );
  }

  updateStore() async {
    NetworkUtil _netUtil = new NetworkUtil();
    await _netUtil.post(Constant.updateAgentPassword, context, body: {
      "id": agentID,
      "password": _passwordController.text,
    }).then((value) async {
      MyToast.showToast(context, value['message']);
      _creatingStore = false;
      reloadState();
      if (value['success'] == true) {
        widget.completed();
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      MyToast.showToast(context, "An Error Occurred");
      print("Error $error");
    });
  }
}
