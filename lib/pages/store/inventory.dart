import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/pages/store/inventory_manager.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/widgets/Dialogs.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key key, @required this.storeCode}) : super(key: key);
  final String storeCode;

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with WidgetsBindingObserver {
  List<dynamic> inventories = [];
  Map<String, dynamic> pagination = Map();
  final ScrollController scrollController = ScrollController();
  TextEditingController _searchInputController;
  final money = new NumberFormat("GHS #,##0.00", "en_US");
  SharedPreferences prefs;

  NetworkUtil _netUtil = new NetworkUtil();
  bool socketConnected = false,
      _loading = true,
      _loadingMore = false,
      _showFAB = true,
      searched = false;
  int resultPerPage = 20, page = 1;
  String searchText = "";

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initData();
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

  initData() async {
    _searchInputController = new TextEditingController();
    _getData();
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
    params["store_code"] = widget.storeCode;
    params["page"] = page;

    await _netUtil
        .post("${Constant.get_inventory}", context, body: params)
        .then((value) {
          setState(() {
            _loading = false;
            _loadingMore = false;
          });
          pagination = value['pagination'];
          if (value['success'] == true) {
            if (more) {
              inventories.insertAll(inventories.length, value['inventories']);
            } else {
              inventories = value['inventories'];
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
        title: Text('Store Inventory'),
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
                        hintText:
                            LocalText.of(context).load('inventory_search'),
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
                      inventories = [];
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
            inventories != null && inventories.length > 0
                ? Column(
                    children: [
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: inventories.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            var inventory = inventories[index];
                            return Container(
                              margin: EdgeInsets.only(
                                  left: 6.0, right: 6.0, bottom: 2.0),
                              child: Card(
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
                                      onTap: () => updateItem(inventory),
                                      onLongPress: () =>
                                          showDeleteModal(inventory),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          10.0, 8.0, 10.0, 8.0),
                                      leading: Icon(
                                        Icons.inventory_sharp,
                                        size: 26,
                                        color: AppColors.pinkMaterial,
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${LocalText.of(context).load('item')}'),
                                          Text(
                                            '${inventory['item']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${LocalText.of(context).load('unit-price')}'),
                                              Text(
                                                  '${money.format(double.parse('${inventory['price']}'))}'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${LocalText.of(context).load('quantity')}'),
                                              Text('${inventory['quantity']}'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${LocalText.of(context).load('date')}'),
                                              Text('${inventory['created']}'),
                                            ],
                                          ),
                                        ],
                                      ),
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
                        '${LocalText.of(context).load('no-inventory-available')}',
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
              onPressed: addItem,
              icon: const Icon(Icons.add),
              label: Text('${LocalText.of(context).load('add-item')}'),
              backgroundColor: AppColors.pinkMaterial,
            )
          : null,
    );
  }

  addItem() {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => InventoryManager(
            inventory: Map(),
            storeCode: widget.storeCode,
            completed: () => _getData(silent: true)));
  }

  updateItem(Map<String, dynamic> inventory) {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => InventoryManager(
            inventory: inventory,
            storeCode: widget.storeCode,
            completed: () => _getData(silent: true)));
  }

  void showDeleteModal(Map<String, dynamic> inventory) {
    showMaterialModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        color: AppColors.nearlyWhite,
        height: 140,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Delete ${inventory['item']} from inventory!",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  letterSpacing: 0.25,
                  color: AppColors.nearlyBlack,
                ),
              ),
              Text(
                "Are you sure you want to delete this item?",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  letterSpacing: 0.15,
                  color: AppColors.dark_grey,
                ),
              ),
              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 60,
                          child: Row(
                            children: [Icon(Icons.cancel), Text("Cancel")],
                          ),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                AppColors.getColor),
                            enableFeedback: true),
                      )),
                  Expanded(child: Container()),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteInventory(inventory['id']);
                        },
                        child: Container(
                          width: 60,
                          child: Row(
                            children: [
                              Icon(Icons.delete_forever),
                              Text("Delete")
                            ],
                          ),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                AppColors.redColor),
                            enableFeedback: true),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void deleteInventory(id) async {
    NetworkUtil _netUtil = new NetworkUtil();
    Dialogs dialogs = new Dialogs();
    dialogs.loading(
        context, "Deleting inventory, Please wait", Dialogs.GLOWING);
    await _netUtil.post("${Constant.delete_inventory}", context,
        body: {"id": id}).then((value) async {
      dialogs.close(context);
      if (value['success'] == true) {
        _getData(silent: true);
      }
    }).catchError((error) {
      dialogs.close(context);
      print("Error $error");
    });
  }
}
