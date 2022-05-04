import 'dart:convert';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/CurrentUser.dart';
import 'package:todays_sales/pages/store/sales_details.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

typedef StringCallback(String code);

class UnSyncHistory extends StatefulWidget {
  const UnSyncHistory(this.storeCode, {Key key}) : super(key: key);
  final String storeCode;

  @override
  _UnSyncHistoryState createState() => _UnSyncHistoryState();
}

class _UnSyncHistoryState extends State<UnSyncHistory> {
  Map<String, dynamic> store;
  List<dynamic> sales = [];
  TextEditingController _searchInputController;
  final money = new NumberFormat("GHS #,##0.00", "en_US");
  DatabaseHelper _databaseHelper = new DatabaseHelper();
  SharedPreferences prefs;

  CurrentUser _currentUser = new CurrentUser();

  bool socketConnected = false,
      _loading = true,
      _loadingMore = false,
      searched = false;
  int resultPerPage = 20, page = 1;
  String searchText = "";
  String _saleTypeOption = "All Sales";

  @override
  void initState() {
    _search();
    super.initState();
  }

  _search() async {
    _searchInputController = new TextEditingController();
    await _currentUser.getUser();
    prefs = await SharedPreferences.getInstance();

    String storeDataPrefs = prefs.getString(
        Constant.storeDataPrefs + widget.storeCode + '${_currentUser.getId()}');
    if (storeDataPrefs != null) {
      store = json.decode(storeDataPrefs);
      if (mounted) {
        setState(() {});
      }
    }

    sales = await _databaseHelper.getSales(
        search: searchText, saleType: _saleTypeOption);
    _loading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyMaterial[100],
      appBar: new AppBar(
        brightness: Brightness.dark,
        title: Text(LocalText.of(context).load("sales-history")),
      ),
      body: ListView(
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${LocalText.of(context).load('un-synced-sales')}',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ).inGridArea('header'),
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
                            LocalText.of(context).load('sales-search-agent'),
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
                      sales = [];
                      page = 1;
                      searched = true;
                      searchText = result;
                      _search();
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
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 2, bottom: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text(
                        "Filter sale type",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          letterSpacing: -0.2,
                          color: AppColors.greyMaterial.withOpacity(.5),
                        ),
                      ),
                      value: _saleTypeOption,
                      isExpanded: true,
                      onChanged: (String newValue) {
                        if (_saleTypeOption != newValue) {
                          _saleTypeOption = newValue;
                          _search();
                        }
                        setState(() {});
                      },
                      icon: Icon(Icons.filter_list_outlined),
                      items: <String>['All Sales', 'Credit Sale', 'Cash Sale']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ).inGridArea('content'),
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
                        _search();
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
            ),
          sales != null && sales.length > 0
              ? Column(
                  children: [
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: sales.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          var sale = sales[index];
                          return Container(
                            margin: EdgeInsets.only(
                                left: 6.0, right: 6.0, bottom: 4.0),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      onTap: () {
                                        openSales(sale, store);
                                      },
                                      leading: Icon(
                                        Icons.receipt,
                                        size: 20,
                                        color: AppColors.pinkMaterial,
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${LocalText.of(context).load('sales-number')}'),
                                          Text(
                                            '${sale['sales_number']}',
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
                                                  '${LocalText.of(context).load('customer-phone')}'),
                                              Text('${sale['customer']}'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${LocalText.of(context).load('total-price')}'),
                                              Text(
                                                  '${money.format(double.parse('${sale['total_price']}'))}'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${LocalText.of(context).load('sales-date')}'),
                                              Text('${sale['datetime']}'),
                                            ],
                                          ),
                                        ],
                                      ),
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
                      '${LocalText.of(context).load('no-sales-available')}',
                      style: TextStyle(
                          color: AppColors.greyMaterial[500],
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  openSales(Map<String, dynamic> sale, Map<String, dynamic> store) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalesDetailsPage(
              store: store,
              salesData: sale,
              isAgent: true,
              isOffline: true,
              done: () {
                _search();
              }),
        ));
  }
}
