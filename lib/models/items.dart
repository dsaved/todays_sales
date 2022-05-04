import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/utils/constant.dart';

class Items {
  String item;
  dynamic id;
  double unitPrice;

  Items({this.item, this.unitPrice, this.id});

  factory Items.fromJson(Map<String, dynamic> parsedJson) {
    return new Items(
        item: parsedJson['item'], unitPrice: double.parse('${parsedJson['price']}'), id: parsedJson['id']);
  }
}

class ItemsViewModel {
  static List<Items> items;

  static Future loadItems(String storeCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      items = [];
      String jsonString = prefs.getString(Constant.itemsListPrefs + storeCode);
      if (jsonString != null) {
        List<dynamic> parsedJson = json.decode(jsonString);
        for (int i = 0; i < parsedJson.length; i++) {
          items.add(new Items.fromJson(parsedJson[i]));
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
