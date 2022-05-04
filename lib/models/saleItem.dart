import 'package:todays_sales/dbhandler/databaseHelper.dart';

class SaleItem {
  String _storeCode,
      _itemID,
      _totalPrice,
      _unitPrice,
      _salesNumber,
      _item,
      _dateTime;
  int _quantity;

  SaleItem.map(dynamic obj) {
    this._storeCode = '${obj['store_code']}';
    this._item = '${obj['item']}';
    this._itemID = '${obj['item_id']}';
    this._totalPrice = '${obj['total_price']}';
    this._unitPrice = '${obj['unit_price']}';
    this._salesNumber = '${'${obj['sales_number']}'}';
    this._dateTime = '${obj['datetime']}';
    this._quantity = int.tryParse('${obj['quantity']}');
  }

  String get itemName => _item;

  String get storeCode => _storeCode;

  String get agentID => _itemID;

  String get totalPrice => _totalPrice;

  String get unitPrice => _unitPrice;

  String get saleNumber => _salesNumber;

  String get dateTime => _dateTime;

  int get quantity => _quantity;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map[DatabaseHelper.KEY_STORE_CODE] = _storeCode;
    map[DatabaseHelper.KEY_ITEM] = _item;
    map[DatabaseHelper.KEY_TOTAL_PRICE] = _totalPrice;
    map[DatabaseHelper.KEY_UNIT_PRICE] = _unitPrice;
    map[DatabaseHelper.KEY_SALES_NUMBER] = _salesNumber;
    map[DatabaseHelper.KEY_ITEM_ID] = _itemID;
    map[DatabaseHelper.KEY_QUANTITY] = _quantity;
    map[DatabaseHelper.KEY_DATETIME] = _dateTime;
    return map;
  }
}
