import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/sale.dart';
import 'package:todays_sales/models/saleItem.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/utils/utils.dart';

class CompletedPage extends StatefulWidget {
  const CompletedPage({Key key, this.store, this.sale, this.saleItems})
      : super(key: key);

  final Map<String, dynamic> store;
  final Sale sale;
  final List<SaleItem> saleItems;

  @override
  _CompletedPageState createState() => _CompletedPageState();
}

class _CompletedPageState extends State<CompletedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.clear,
              color: Colors.black54,
            )),
        backgroundColor: Colors.white,
        elevation: 0,
        brightness: Brightness.light,
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 200,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Constant.doneSVG,
                    height: 100,
                  ),
                  Text(
                    '${LocalText.of(context).load('thank_you')}',
                    style: TextStyle(
                        fontSize: 21, color: AppColors.greyMaterial[600]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${LocalText.of(context).load('order_confirmed')}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyMaterial[900]),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 250,
                    child: Text(
                      '${LocalText.of(context).load('order_confirmed_info')}',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.greyMaterial[500]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 150,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.pinkMaterial,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: AppColors.pinkMaterial.withOpacity(0.5),
                              offset: const Offset(1.1, 1.1),
                              blurRadius: 10.0),
                        ],
                      ),
                      child: Center(
                        child: Text('${LocalText.of(context).load('done')}',
                            style:
                                TextStyle(color: Colors.white, fontSize: 22)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: (widget.sale.saleType == 0)
          ? FloatingActionButton.extended(
              onPressed: () => Utils.printReceipt(
                  widget.store, widget.sale, widget.saleItems),
              icon: Icon(Icons.print),
              label: Text('${LocalText.of(context).load('print')}'),
              backgroundColor: AppColors.indigoMaterial,
            )
          : null,
    );
  }
}
