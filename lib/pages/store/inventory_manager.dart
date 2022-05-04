import 'dart:ui';

import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/widgets/Dialogs.dart';
import 'package:todays_sales/widgets/toast.dart';

class InventoryManager extends StatefulWidget {
  const InventoryManager({Key key, this.inventory, this.storeCode, @required this.completed})
      : super(key: key);

  final Map<String, dynamic> inventory;
  final String storeCode;
  final VoidCallback completed;

  @override
  _InventoryManagerState createState() => _InventoryManagerState();
}

class _InventoryManagerState extends State<InventoryManager> {
  SharedPreferences prefs;
  Map<String, dynamic> inventory;
  double opacity3 = 0.0;
  String type = "Add",
      loading_status = "Adding",
      success_status = "Added",
      id,
      link = Constant.add_inventory;

  TextEditingController _itemController, _priceController,_quantityController,_descriptionController;

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController();
    _descriptionController = TextEditingController();
    initAll();
  }

  void initAll() async {
    prefs = await SharedPreferences.getInstance();

    inventory = widget.inventory;
    if (inventory != null && inventory.isNotEmpty) {
      link = Constant.update_inventory;
      type = "Update";
      loading_status = "Updating";
      success_status = "Updated";
      id = "${inventory['id']}";

      _itemController.text = "${inventory['item']}";
      _priceController.text = "${inventory['price']}";
      _quantityController.text = "${inventory['quantity']}";
      _descriptionController.text = "${inventory['description']}";
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
          "$type item",
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
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  controller: _itemController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${LocalText.of(context).load('item')}',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  controller: _priceController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${LocalText.of(context).load('unit-price')}',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${LocalText.of(context).load('quantity')}',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: TextField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '${LocalText.of(context).load('description')}',
                  ),
                  onSubmitted: (_) => submitForm(),
                ),
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
                          onTap: submitForm,
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

  submitForm() {
    if (_itemController.text.isEmpty) {
      return showToast('${LocalText.of(context).load('item_required')}');
    }
    if (_priceController.text.isEmpty) {
      return showToast('${LocalText.of(context).load('price_required')}');
    }
    if (_quantityController.text.isEmpty) {
      return showToast('${LocalText.of(context).load('quantity_required')}');
    }
    Map<String, dynamic> _inventory = new Map();
    _inventory['id'] = id;
    _inventory['item'] = _itemController.text;
    _inventory['price'] = _priceController.text;
    _inventory['quantity'] = _quantityController.text;
    _inventory['description'] = _descriptionController.text;
    _inventory['store_code'] = widget.storeCode;
    addInventory(_inventory);
  }

  void addInventory(Map<String, dynamic> inventory) async {
    NetworkUtil _netUtil = new NetworkUtil();
    Dialogs dialogs = new Dialogs();
    dialogs.loading(
        context, "$loading_status item, Please wait", Dialogs.GLOWING);
    await _netUtil.post("$link", context, body: inventory).then((value) async {
      dialogs.close(context);
      if (value['success'] == true) {
        await dialogs.infoDialog(context, "Completed",
            "The item has been $success_status successfully",
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
