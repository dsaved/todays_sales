import 'dart:async';
import 'dart:io' as io;

import 'package:todays_sales/models/sale.dart';
import 'package:todays_sales/models/saleItem.dart';
import 'package:todays_sales/models/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  // All Static variables
  // Database Version
  // ignore: non_constant_identifier_names
  static final int DATABASE_VERSION = 1;

  // ignore: non_constant_identifier_names
  static final String DATABASE_NAME = "todays_sales";

  // User Table Columns names
  // ignore: non_constant_identifier_names
  static final String KEY_ID = "id";

  // ignore: non_constant_identifier_names
  static final String TABLE_USER = "user";

  // ignore: non_constant_identifier_names
  static final String KEY_NAME = "name";

  // ignore: non_constant_identifier_names
  static final String KEY_PHONE = "phone";

  // ignore: non_constant_identifier_names
  static final String KEY_GENDER = "gender";

  // ignore: non_constant_identifier_names
  static final String KEY_ADDRESS = "address";

  // ignore: non_constant_identifier_names
  static final String KEY_TYPE = "type";

  // ignore: non_constant_identifier_names
  static final String KEY_UID = "uid";

  // ignore: non_constant_identifier_names
  static final String KEY_AUTH = "authentication";

  // ignore: non_constant_identifier_names
  static final String TABLE_SALES = "sales";

  // ignore: non_constant_identifier_names
  static final String TABLE_SALES_ITEMS = "sales_items";

  // ignore: non_constant_identifier_names
  static final String KEY_SALES_NUMBER = "sales_number";

  // ignore: non_constant_identifier_names
  static final String KEY_SALES_TYPE = "sale_type";

  // ignore: non_constant_identifier_names
  static final String KEY_STORE_CODE = "store_code";

  // ignore: non_constant_identifier_names
  static final String KEY_TOTAL_PRICE = "total_price";

  // ignore: non_constant_identifier_names
  static final String KEY_AGENT_ID = "agent_id";

  // ignore: non_constant_identifier_names
  static final String KEY_AGENT_NAME = "agent_name";

  // ignore: non_constant_identifier_names
  static final String KEY_AGENT_PHONE = "agent_phone";

  // ignore: non_constant_identifier_names
  static final String KEY_CUSTOMER = "customer";

  // ignore: non_constant_identifier_names
  static final String KEY_DATETIME = "datetime";

  // ignore: non_constant_identifier_names
  static final String KEY_ITEM = "item";

  // ignore: non_constant_identifier_names
  static final String KEY_QUANTITY = "quantity";

  // ignore: non_constant_identifier_names
  static final String KEY_UNIT_PRICE = "unit_price";

  // ignore: non_constant_identifier_names
  static final String KEY_ITEM_ID = "item_id";

  // ignore: non_constant_identifier_names
  String CREATE_LOGIN_TABLE = "CREATE TABLE " +
      TABLE_USER +
      "(" +
      KEY_ID +
      " INTEGER PRIMARY KEY," +
      KEY_NAME +
      " TEXT," +
      KEY_TYPE +
      " TEXT," +
      KEY_PHONE +
      " TEXT," +
      KEY_GENDER +
      " TEXT," +
      KEY_ADDRESS +
      " TEXT," +
      KEY_UID +
      " TEXT," +
      KEY_AUTH +
      " TEXT)";

  // ignore: non_constant_identifier_names
  String CREATE_SALES_TABLE = "CREATE TABLE " +
      TABLE_SALES +
      "(" +
      KEY_ID +
      " INTEGER PRIMARY KEY," +
      KEY_STORE_CODE +
      " TEXT," +
      KEY_AGENT_ID +
      " TEXT," +
      KEY_AGENT_NAME +
      " TEXT," +
      KEY_AGENT_PHONE +
      " TEXT," +
      KEY_TOTAL_PRICE +
      " TEXT," +
      KEY_SALES_TYPE +
      " INTEGER," +
      KEY_SALES_NUMBER +
      " TEXT," +
      KEY_CUSTOMER +
      " TEXT," +
      KEY_DATETIME +
      " TEXT)";

  // ignore: non_constant_identifier_names
  String CREATE_SALES_ITEM_TABLE = "CREATE TABLE " +
      TABLE_SALES_ITEMS +
      "(" +
      KEY_ID +
      " INTEGER PRIMARY KEY," +
      KEY_SALES_NUMBER +
      " TEXT," +
      KEY_STORE_CODE +
      " TEXT," +
      KEY_ITEM +
      " TEXT," +
      KEY_QUANTITY +
      " TEXT," +
      KEY_UNIT_PRICE +
      " TEXT," +
      KEY_TOTAL_PRICE +
      " TEXT," +
      KEY_ITEM_ID +
      " TEXT," +
      KEY_DATETIME +
      " TEXT)";

  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DATABASE_NAME);
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(CREATE_LOGIN_TABLE);
    await db.execute(CREATE_SALES_TABLE);
    await db.execute(CREATE_SALES_ITEM_TABLE);
  }

  Future<int> saveUser(User user) async {
    var dbClient = await db;
    int res = await dbClient.insert(TABLE_USER, user.toMap());
    return res;
  }

  Future<int> updateUser(User user) async {
    var dbClient = await db;
    int res = await dbClient
        .update(TABLE_USER, user.toMap(), where: '$KEY_ID =?', whereArgs: [1]);
    return res;
  }

  Future<int> deleteUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete(TABLE_USER);
    return res;
  }

  Future<bool> isLoggedIn() async {
    var dbClient = await db;
    var res = await dbClient.query(TABLE_USER);
    return res.length > 0 ? true : false;
  }

  Future getUser() async {
    var dbClient = await db;
    var res = await dbClient.query(TABLE_USER);
    return res.length > 0 ? res.first : Map<String, dynamic>();
  }

  Future authentication() async {
    var dbClient = await db;
    var res = await dbClient.query(TABLE_USER);
    return res.length > 0 ? res.first[KEY_AUTH] : null;
  }

  Future userType() async {
    var dbClient = await db;
    var res = await dbClient.query(TABLE_USER);
    return res.length > 0 ? res.first[KEY_TYPE] : null;
  }

  Future saveSale(Sale sale, List<SaleItem> items) async {
    var dbClient = await db;
    int res = await dbClient.insert(TABLE_SALES, sale.toMap());
    for (int i = 0; i < items.length; i++) {
      var item = items[i];
      await dbClient.insert(TABLE_SALES_ITEMS, item.toMap());
    }
    return res;
  }

  Future<int> updateSaleType(int type, String saleNumber) async {
    var dbClient = await db;
    int res = await dbClient
        .update(TABLE_SALES, {"sale_type": type}, where: '$KEY_SALES_NUMBER =?', whereArgs: [saleNumber]);
    return res;
  }

  Future<int> deleteSale(String saleNumber) async {
    var dbClient = await db;
    int res = await dbClient.delete(TABLE_SALES,
        where: '$KEY_SALES_NUMBER =?', whereArgs: [saleNumber]);
    await dbClient.delete(TABLE_SALES_ITEMS,
        where: '$KEY_SALES_NUMBER =?', whereArgs: [saleNumber]);
    return res;
  }

  Future getSales({String search, String saleType}) async {
    if (saleType=='All Sales') saleType = null;
    List<Map<String, dynamic>> sales = [];
    var dbClient = await db;
    var res;
    if (search != null &&
        search.isNotEmpty &&
        saleType != null &&
        saleType.isNotEmpty) {
      int _type = -10;
      if (saleType == 'Cash Sale') {
        _type = 0;
      } else if (saleType == 'Credit Sale') {
        _type = 1;
      }
      res = await dbClient.query(
        TABLE_SALES,
        where: '$KEY_SALES_NUMBER =? OR $KEY_CUSTOMER =? OR $KEY_SALES_TYPE =?',
        whereArgs: [search, search, _type],
        orderBy: '$KEY_ID DESC',
      );
    } else if (search != null && search.isNotEmpty) {
      res = await dbClient.query(
        TABLE_SALES,
        where: '$KEY_SALES_NUMBER =? OR $KEY_CUSTOMER =?',
        whereArgs: [search, search],
        orderBy: '$KEY_ID DESC',
      );
    } else if (saleType != null && saleType.isNotEmpty) {
      int _type = -10;
      if (saleType == 'Cash Sale') {
        _type = 0;
      } else if (saleType == 'Credit Sale') {
        _type = 1;
      }
      res = await dbClient.query(
        TABLE_SALES,
        where: '$KEY_SALES_TYPE =?',
        whereArgs: [_type],
        orderBy: '$KEY_ID DESC',
      );
    } else {
      res = await dbClient.query(TABLE_SALES, orderBy: '$KEY_ID DESC');
    }
    if (res.length > 0) {
      int index = 0;
      for (index = 0; index < res.length; index++) {
        var item = res[index];
        Map<String, dynamic> sale = new Map();
        sale['sales_number'] = item[KEY_SALES_NUMBER];
        sale['store_code'] = item[KEY_STORE_CODE];
        sale['agent_id'] = item[KEY_AGENT_ID];
        sale['agent_name'] = item[KEY_AGENT_NAME];
        sale['agent_phone'] = item[KEY_AGENT_PHONE];
        sale['sale_type'] = item[KEY_SALES_TYPE];
        sale['customer'] = item[KEY_CUSTOMER];
        sale['datetime'] = item[KEY_DATETIME];
        sale['total_price'] = item[KEY_TOTAL_PRICE];
        List<Map<String, dynamic>> items = [];
        var saleItems = await dbClient.query(
          TABLE_SALES_ITEMS,
          where: KEY_SALES_NUMBER + "=?",
          whereArgs: ['${item[KEY_SALES_NUMBER]}'],
          orderBy: '$KEY_ID DESC',
        );
        if (saleItems.length > 0) {
          for (int i = 0; i < saleItems.length; i++) {
            var saleItem = saleItems[i];
            items.add(saleItem);
          }
        }
        sale['sales_items'] = items;
        sales.add(sale);
      }
    }
    return sales;
  }
}
