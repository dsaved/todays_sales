import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/CurrentUser.dart';
import 'package:todays_sales/models/items.dart';
import 'package:todays_sales/models/sale.dart';
import 'package:todays_sales/models/saleItem.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/pages/store/complete_sale.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/utils/utils.dart';
import 'package:todays_sales/widgets/Dialogs.dart';
import 'package:todays_sales/widgets/toast.dart';

class NewSalePage extends StatefulWidget {
  const NewSalePage({Key key, this.store}) : super(key: key);
  final Map<String, dynamic> store;

  @override
  _NewSalePageState createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final money = new NumberFormat("GHS #,##0.00", "en_US");
  DatabaseHelper _databaseHelper = new DatabaseHelper();

  NetworkUtil _netUtil = new NetworkUtil();
  bool socketConnected = false, _loading = false, searched = false;
  int resultPerPage = 20, page = 1;
  String searchText = "";
  CurrentUser user = new CurrentUser();
  List<dynamic> itemList = [];
  Dialogs _dialogs = new Dialogs();
  SharedPreferences prefs;
  TextEditingController _itemController, _quantityController, _priceController;
  double priceSum = 0.0;
  String storeCode = '', _itemID = '0';
  GlobalKey<AutoCompleteTextFieldState<Items>> key = new GlobalKey();

  final FocusNode _itemFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();
  final FocusNode _quantityFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _itemController = new TextEditingController();
    _quantityController = new TextEditingController();
    _priceController = new TextEditingController();
    initialize();
  }

  initialize() async {
    prefs = await SharedPreferences.getInstance();
    storeCode = prefs.getString(Constant.storeCodePrefs);
    await user.getUser();
    FocusScope.of(context).requestFocus(_itemFocus);
    getItems();
  }

  loadItems() async {
    Timer(Duration(milliseconds: 800), getItems);
  }

  getItems() {
    priceSum = 0.0;
    var items = prefs.get(Constant.itemListPrefs);
    if (items != null) {
      itemList = json.decode(items);
    } else {
      itemList = [];
    }
    itemList.forEach((item) {
      priceSum += double.parse('${item['total_price']}');
    });
    reloadState();
  }

  reloadState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        brightness: Brightness.dark,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.clear)),
        actions: [
          IconButton(
            onPressed: () {
              Utils.clearItem(context);
              loadItems();
            },
            icon: Icon(Icons.refresh_outlined),
            tooltip: '${LocalText.of(context).load("clear_list")}',
          ),
        ],
        title: Text(LocalText.of(context).load("new-sale")),
      ),
      body: ListView(
        children: [
          Card(
            elevation: 0,
            margin: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutGrid(
                    areas: '''
                      header header
                      item item
                      unit_price quantity
                    ''',
                    columnSizes: [auto, auto],
                    rowSizes: [auto, auto, auto],
                    columnGap: 12,
                    rowGap: 12,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 3.0, right: 3.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: AutoCompleteTextField<Items>(
                                  key: key,
                                  controller: _itemController,
                                  submitOnSuggestionTap: true,
                                  clearOnSubmit: false,
                                  suggestions: ItemsViewModel.items,
                                  textInputAction: TextInputAction.next,
                                  focusNode: _itemFocus,
                                  textChanged: (item) {},
                                  itemSubmitted: (item) {
                                    _itemController.text = '${item.item}';
                                    _itemID = '${item.id}';
                                    _priceController.text = '${item.unitPrice}';
                                    _itemFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_priceFocus);
                                    reloadState();
                                  },
                                  decoration: InputDecoration(
                                      hintMaxLines: 1,
                                      hintText:
                                          LocalText.of(context).load('item')),
                                  itemBuilder: (context, item) {
                                    return new Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: new Text(
                                          item.item,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ));
                                  },
                                  itemSorter: (a, b) {
                                    return a.item.compareTo(b.item);
                                  },
                                  itemFilter: (item, query) {
                                    return item.item
                                        .toLowerCase()
                                        .startsWith(query.toLowerCase());
                                  }),
                            ),
                          ],
                        ),
                      ).inGridArea('item'),
                      Container(
                        padding: EdgeInsets.only(left: 3.0, right: 3.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _priceController,
                                textInputAction: TextInputAction.next,
                                focusNode: _priceFocus,
                                maxLines: 1,
                                decoration: InputDecoration(
                                    hintMaxLines: 1,
                                    hintText: LocalText.of(context)
                                        .load('unit-price')),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ).inGridArea('unit_price'),
                      Container(
                        padding: EdgeInsets.only(left: 3.0, right: 3.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                  controller: _quantityController,
                                  focusNode: _quantityFocus,
                                  textInputAction: TextInputAction.done,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      hintMaxLines: 1,
                                      hintText: LocalText.of(context)
                                          .load('quantity')),
                                  keyboardType: TextInputType.number,
                                  onSubmitted: (term) {
                                    _addItem();
                                    _quantityFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_itemFocus);
                                  }),
                            ),
                          ],
                        ),
                      ).inGridArea('quantity'),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${LocalText.of(context).load('total-price')} ${money.format(priceSum)}",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Text(
                              "${LocalText.of(context).load('item')}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${LocalText.of(context).load('Unit')}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${LocalText.of(context).load('Qty')}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${LocalText.of(context).load('Total')}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      ListView(
                        primary: false,
                        shrinkWrap: true,
                        children: <Widget>[
                          Builder(builder: (BuildContext context) {
                            List<Widget> widgetData = [];
                            for (var i = 0; i < itemList.length; i++) {
                              widgetData.add(Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "${itemList[i]['item']}",
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${itemList[i]['unit_price']}",
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${itemList[i]['quantity']}",
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${itemList[i]['total_price']}",
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        Utils.removeItem(context, itemList, i);
                                        loadItems();
                                      },
                                      child: Icon(
                                        Icons.delete_forever,
                                        color: AppColors.darkPinkMaterial,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                              widgetData.add(SizedBox(height: 4.0));
                            }
                            var widgets = Column(
                              children: widgetData,
                            );
                            return widgets;
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitSale,
        icon: _loading
            ? SpinKitRing(
                lineWidth: 4.0,
                color: Colors.white,
                size: 30,
              )
            : Icon(Icons.send),
        label: Text('${LocalText.of(context).load('process')}'),
        backgroundColor: AppColors.pinkMaterial,
      ),
    );
  }

  _addItem() async {
    if (_itemController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      String item = _itemController.text;
      String quantity = _quantityController.text;
      String price = _priceController.text;
      String itemID = _itemID;
      await Utils.addItem(context, item, double.parse(price), itemID,
          qty: quantity);
      _itemController.text = "";
      _quantityController.text = "";
      _priceController.text = "";
      _itemID = "";
      loadItems();
    }
  }

  _submitSale() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    if (itemList.length < 1) {
      MyToast.showToast(context, LocalText.of(context).load("item_list_empty"));
      return false;
    }

    _dialogs.confirm(context, LocalText.of(context).load('confirm-sale'),
        LocalText.of(context).load('confirm-sale-description'),
        onPressed: (confirmed) {
      if (confirmed) {
        _dialogs.inputDialog(
            context, LocalText.of(context).load('customer_hint'),
            keyboardType: TextInputType.number, onPressed: (value) async {
          if (value != null && value.isNotEmpty) {
            _dialogs.cashCreditDialog(context, onPressed: (creditOrCash) async {
              _loading = true;
              reloadState();

              Map<String, dynamic> sale = new Map();
              sale["store_code"] = storeCode;
              sale["customer"] = value;
              sale["agent_id"] = '${user.getId()}';
              sale["agent_name"] = '${user.getName()}';
              sale["agent_phone"] = '${user.getPhone()}';
              sale["total_price"] = '$priceSum';
              sale["sales_number"] = '${now.millisecondsSinceEpoch}';
              sale["datetime"] = '$formattedDate';
              sale["sale_type"] = creditOrCash;

              List<Map<String, dynamic>> saleItems = [];
              List<SaleItem> saleItemsMap = [];
              itemList.forEach((item) {
                Map<String, dynamic> itemData = Map();
                itemData['item'] = item['item'];
                itemData["store_code"] = storeCode;
                itemData['unit_price'] = '${item['unit_price']}';
                itemData['quantity'] = '${item['quantity']}';
                itemData['item_id'] = '${item['id']}';
                itemData["sales_number"] = '${now.millisecondsSinceEpoch}';
                itemData['total_price'] = '${item['total_price']}';
                itemData["datetime"] = '$formattedDate';
                saleItems.add(itemData);
                saleItemsMap.add(SaleItem.map(itemData));
              });
              sale["sales_items"] = json.encode(saleItems);
              var _sale = Sale.map(sale);
              var response =
                  await _databaseHelper.saveSale(_sale, saleItemsMap);
              if (response > 0) {
                await _netUtil
                    .post("${Constant.saleRequest}", context, body: sale)
                    .then((value) async {
                      _loading = false;
                      Utils.clearItem(context);
                      reloadState();
                      if (value['success'] == true) {
                        await _databaseHelper
                            .deleteSale('${now.millisecondsSinceEpoch}');
                      }
                      showComplete(_sale, saleItemsMap);
                    })
                    .timeout(Duration(seconds: 10))
                    .catchError((error) {
                      _loading = false;
                      reloadState();
                      showComplete(_sale, saleItemsMap);
                    });
              }
            });
          }
        });
      }
    });
  }

  showComplete(Sale sale, List<SaleItem> saleItems) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompletedPage(
            sale: sale,
            saleItems: saleItems,
            store: widget.store,
          ),
        ));
  }
}
