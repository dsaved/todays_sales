import 'package:todays_sales/dbhandler/databaseHelper.dart';

class Sale {
  String _storeCode,
      _agentID,
      _agentName,
      _agentPhone,
      _totalPrice,
      _salesNumber,
      _customer,
      _dateTime;

  int _saleType;

  Sale.map(dynamic obj) {
    this._storeCode = '${obj['store_code']}';
    this._customer = '${obj['customer']}';
    this._agentID = '${obj['agent_id']}';
    this._agentName = '${obj['agent_name']}';
    this._agentPhone = '${obj['agent_phone']}';
    this._totalPrice = '${obj['total_price']}';
    this._salesNumber = '${obj['sales_number']}';
    this._dateTime = '${obj['datetime']}';
    this._saleType = int.parse('${obj['sale_type']}');
  }

  String get storeCode => _storeCode;

  String get agentID => _agentID;

  String get agentName => _agentName;

  String get agentPhone => _agentPhone;

  String get customer => _customer;

  String get totalPrice => _totalPrice;

  String get saleNumber => _salesNumber;

  String get dateTime => _dateTime;

  int get saleType => _saleType;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map[DatabaseHelper.KEY_STORE_CODE] = _storeCode;
    map[DatabaseHelper.KEY_CUSTOMER] = _customer;
    map[DatabaseHelper.KEY_TOTAL_PRICE] = _totalPrice;
    map[DatabaseHelper.KEY_SALES_NUMBER] = _salesNumber;
    map[DatabaseHelper.KEY_SALES_TYPE] = _saleType;
    map[DatabaseHelper.KEY_AGENT_ID] = _agentID;
    map[DatabaseHelper.KEY_AGENT_NAME] = _agentName;
    map[DatabaseHelper.KEY_AGENT_PHONE] = _agentPhone;
    map[DatabaseHelper.KEY_DATETIME] = _dateTime;
    return map;
  }
}
