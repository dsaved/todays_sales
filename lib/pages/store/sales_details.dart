import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/sale.dart';
import 'package:todays_sales/models/saleItem.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/utils/utils.dart';
import 'package:todays_sales/widgets/Dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class SalesDetailsPage extends StatefulWidget {
  const SalesDetailsPage(
      {Key key,
      @required this.salesData,
      @required this.store,
      this.isAgent,
      this.isOffline = false,
      this.done})
      : super(key: key);
  final Map<String, dynamic> salesData;
  final Map<String, dynamic> store;
  final bool isAgent, isOffline;
  final VoidCallback done;

  @override
  _SalesDetailsPageState createState() => _SalesDetailsPageState();
}

class _SalesDetailsPageState extends State<SalesDetailsPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final money = new NumberFormat("GHS #,##0.00", "en_US");
  dynamic saleType = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    saleType = widget.salesData['sale_type'];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.salesData;
    bool isAgent = widget.isAgent;

    List<SaleItem> saleItemsMap = [];
    data['sales_items'].forEach((item) {
      Map<String, dynamic> itemData = Map();
      itemData['item'] = item['item'];
      itemData["store_code"] = '${item['store_code']}';
      itemData['unit_price'] = '${item['unit_price']}';
      itemData['quantity'] = '${item['quantity']}';
      itemData['item_id'] = '${item['item_id']}';
      itemData["sales_number"] = '${item['sales_number']}';
      itemData['total_price'] = '${item['total_price']}';
      itemData["datetime"] = '${item['datetime']}';
      saleItemsMap.add(SaleItem.map(itemData));
    });

    return Scaffold(
      backgroundColor: AppColors.greyMaterial[100],
      appBar: new AppBar(
        brightness: Brightness.dark,
        title: Text(
            '${LocalText.of(context).load('sales-details')} (${data['store_code']})'),
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Positioned(
                right: -50,
                top: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: SizedBox(
                    height: 150,
                    child: AspectRatio(
                      aspectRatio: 1.714,
                      child: Opacity(
                          opacity: 0.2,
                          child: Image.asset(Constant.card_bottom_left)),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -140,
                top: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: SizedBox(
                    height: 180,
                    child: AspectRatio(
                      aspectRatio: 1.714,
                      child: Opacity(
                          opacity: 0.3,
                          child: Image.asset(Constant.card_top_right)),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20.0,
                      child: Icon(
                        Icons.receipt,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '${data['sales_number']}'.toUpperCase(),
                      style: TextStyle(
                          color: AppColors.pinkMaterial,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${data['agent_name']} (${data['agent_phone']})',
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.9),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 5.0, bottom: 15.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 20,
                              color: AppColors.greyMaterial[600],
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: MediaQuery.of(context).size.width - 80,
                              child: Text(
                                '${data['customer']}',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.9),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.money_sharp,
                              size: 20,
                              color: AppColors.greyMaterial[600],
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: MediaQuery.of(context).size.width - 80,
                              child: Text(
                                '${money.format(double.parse('${data['total_price']}'))}',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.9),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: 20,
                              color: AppColors.greyMaterial[600],
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: MediaQuery.of(context).size.width - 80,
                              child: Text(
                                '${data['datetime']}',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.9),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 5.0, bottom: 15.0),
                    child: Column(
                      children: [
                        if (saleType == 1)
                          ElevatedButton(
                            onPressed: () {
                              paidFor("${data['id']}");
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.pinkAccent)),
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                '${LocalText.of(context).load('paid')}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!isAgent)
                              ElevatedButton(
                                onPressed: () {
                                  launch("tel://${data['agent_phone']}");
                                },
                                child: Container(
                                  width: 100,
                                  child: Text(
                                    '${LocalText.of(context).load('call-sales-agent')}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ElevatedButton(
                              onPressed: () {
                                launch("tel://${data['customer']}");
                              },
                              child: Container(
                                width: 100,
                                child: Text(
                                  '${LocalText.of(context).load('call-customer')}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
          Container(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data['sales_items'].length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var saleItem = data['sales_items'][index];
                return Container(
                  margin: EdgeInsets.only(left: 6.0, right: 6.0, bottom: 4.0),
                  child: Card(
                    elevation: 1,
                    child: Stack(
                      children: [
                        Positioned(
                          left: -50,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            child: SizedBox(
                              height: 150,
                              child: AspectRatio(
                                aspectRatio: 1.714,
                                child: Opacity(
                                    opacity: 0.04,
                                    child:
                                        Image.asset(Constant.card_bottom_left)),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Icon(
                              Icons.list_alt,
                              size: 20,
                              color: AppColors.pinkMaterial,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${LocalText.of(context).load('item')}'),
                                Text(
                                  '${saleItem['item']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${LocalText.of(context).load('quantity')}'),
                                    Text('${saleItem['quantity']}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${LocalText.of(context).load('unit-price')}'),
                                    Text(
                                        '${money.format(double.parse('${saleItem['unit_price']}'))}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${LocalText.of(context).load('total-price')}'),
                                    Text(
                                        '${money.format(double.parse('${saleItem['total_price']}'))}'),
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
        ],
      ),
      floatingActionButton: (saleType == 0)
          ? FloatingActionButton.extended(
              onPressed: () => Utils.printReceipt(
                  widget.store, Sale.map(data), saleItemsMap),
              icon: Icon(Icons.print),
              label: Text('${LocalText.of(context).load('print')}'),
              backgroundColor: AppColors.pinkMaterial,
            )
          : null,
    );
  }

  paidFor(String salesID) async {
    Dialogs _dialogs = Dialogs();
    NetworkUtil _netUtil = NetworkUtil();
    _dialogs.confirm(context, LocalText.of(context).load('confirm-sale'),
        LocalText.of(context).load('confirm-sale-paid-description'),
        onPressed: (confirmed) async {
      if (confirmed) {
        if (!widget.isOffline) {
          _dialogs.loading(context, LocalText.of(context).load('updating-sale'),
              Dialogs.SCALE_TRANSITION);
          await _netUtil
              .post("${Constant.salesPaidFor}", context, body: {"id": salesID})
              .then((value) async {
                _dialogs.close(context);
                if (value['success'] == true) {
                  saleType = 0;
                  setState(() {});
                  widget.done();
                }
              })
              .timeout(Duration(seconds: 10))
              .catchError((error) {
                _dialogs.close(context);
              });
        } else {
          DatabaseHelper _databaseHelper = DatabaseHelper();
          var response = await _databaseHelper.updateSaleType(
              0, widget.salesData['sales_number']);
          if (response > 0) {
            saleType = 0;
            setState(() {});
            widget.done();
          }
        }
      }
    });
  }
}
