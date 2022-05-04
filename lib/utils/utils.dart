import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/sale.dart';
import 'package:todays_sales/models/saleItem.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/widgets/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todays_sales/resources/theme.dart' as appTheme;
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Utils {
  static var _monthNames = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER'
  ];

  static Future<String> get getStorageDir async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> get getFileDir async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  static getImage(image) {
    if (hasData(image)) {
      var hasHttps = (image.indexOf('https://') < 0) ? false : true;
      var hasHttp = (image.indexOf('http://') < 0) ? false : true;
      if (hasHttps || hasHttp) {
        return image;
      }
      return Constant.baseUrl + image;
    }
    return Constant.baseUrl +
        "library/image.php?crtimage=1&setting=ffffff_000000_300_300&text=No%20Image";
  }

  static bool fileExist(dir) {
    if (FileSystemEntity.typeSync("$dir") == FileSystemEntityType.file) {
      return true;
    } else {
      return false;
    }
  }

  static Future addItem(BuildContext context, String drug, double unitPrice,dynamic id,
      {qty = 1}) async {
    List<dynamic> itemList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var items = prefs.getString(Constant.itemListPrefs);
    if (items != null) {
      bool exist = false;
      itemList = json.decode(items);
      itemList.forEach((list) {
        if (list["id"] == id) {
          int _qty = int.parse("${list["quantity"]}") + int.parse(qty);
          list["quantity"] = _qty;
          list["total_price"] =
              double.parse('$_qty') * double.parse('${list["unit_price"]}');
          exist = true;
        }
      });

      if (!exist) {
        Map<String, dynamic> _item = Map();
        _item["id"] = id;
        _item["item"] = drug;
        _item["unit_price"] = unitPrice;
        _item["quantity"] = qty;
        _item["total_price"] = double.parse('$qty') * unitPrice;
        itemList.add(_item);
        prefs.setString(Constant.itemListPrefs, json.encode(itemList));
        MyToast.showToast(context,LocalText.of(context).load("item_added"));
      } else {
        prefs.setString(Constant.itemListPrefs, json.encode(itemList));
        MyToast.showToast(context,LocalText.of(context).load("item_added"));
      }
    } else {
      Map<String, dynamic> _item = Map();
      _item["id"] = id;
      _item["item"] = drug;
      _item["unit_price"] = unitPrice;
      _item["quantity"] = qty;
      _item["total_price"] = double.parse('$qty') * unitPrice;
      itemList.add(_item);
      prefs.setString(Constant.itemListPrefs, json.encode(itemList));
      MyToast.showToast(context,LocalText.of(context).load("item_added"));
    }
  }

  static printReceipt(
      Map<String, dynamic> store, Sale sale, List<SaleItem> saleItems) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 215,
                  child: pw.Text(
                    '${store['store_name']}'.toUpperCase(),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  width: 215,
                  child: pw.Text(
                    '${store['store_address']} ${store['store_location']}'
                        .toUpperCase(),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  width: 215,
                  child: pw.Text(
                    'Store code: ${sale.storeCode}'.toUpperCase(),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  width: 215,
                  child: pw.Text(
                    'Tel: ${store['phone']}'.toUpperCase(),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Text('*********************************************'),
                pw.Text('*********************************************'),
                pw.SizedBox(height: 8.0),
                pw.Text('Order: ${sale.saleNumber}'),
                pw.Text('Date: ${sale.dateTime}'),
                pw.SizedBox(height: 8.0),
                pw.Container(
                  width: 215,
                  child: pw.ListView(children: <pw.Widget>[
                    pw.Builder(builder: (context) {
                      List<pw.Widget> widgetData = [];
                      for (var i = 0; i < saleItems.length; i++) {
                        widgetData.add(pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: <pw.Widget>[
                            pw.Expanded(
                              flex: 4,
                              child: pw.Text(
                                "${saleItems[i].itemName}",
                                style: pw.TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                "${saleItems[i].unitPrice}",
                                style: pw.TextStyle(
                                  fontSize: 11,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                "${saleItems[i].quantity}",
                                style: pw.TextStyle(
                                  fontSize: 11,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                "${saleItems[i].totalPrice}",
                                style: pw.TextStyle(
                                  fontSize: 11,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ));
                        widgetData.add(pw.SizedBox(height: 4.0));
                      }
                      widgetData.add(pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 4,
                            child: pw.Text(
                              "Total Price",
                              style: pw.TextStyle(
                                  fontSize: 11, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Expanded(
                            flex: 6,
                            child: pw.Text(
                              "GHS ${sale.totalPrice}",
                              style: pw.TextStyle(
                                fontSize: 11,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ));
                      var widgets = pw.Column(
                        children: widgetData,
                      );
                      return widgets;
                    }),
                  ]),
                ),
                pw.SizedBox(height: 8.0),
                pw.Text(
                  'You where served by:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text('Cashier: ${sale.agentID}, ${sale.agentName}'),
                pw.SizedBox(height: 8.0),
                pw.Text('*********************************************'),
                pw.Container(
                  width: 215,
                  child: pw.Text('Thanks for shopping!',
                      textAlign: pw.TextAlign.center),
                ),
              ],
            );
          }),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
    // await Printing.sharePdf(bytes: await doc.save(), filename: 'my-document.pdf');
  }

  static Future removeItem(
      BuildContext context, List<dynamic> items, index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    items.removeAt(index);
    prefs.setString(Constant.itemListPrefs, json.encode(items));
    MyToast.showToast(context,LocalText.of(context).load("item_removed"));
  }

  static Future clearItem(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(Constant.itemListPrefs);
    MyToast.showToast(context,LocalText.of(context).load("list_cleared"));
  }

  static bool hasData(data) {
    return null != data && data.length > 0;
  }

  static Future<File> writeToFile(ByteData data, String path, String filename) {
    print("writing file $filename...");
    final buffer = data.buffer;
    return File("$path/$filename").writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static bool isEmpty(data) {
    return data == null || data.isEmpty || data == "null";
  }

  static bool isNotEmpty(data) {
    return data != null && data.isNotEmpty && data != 'null';
  }

  static bool exist(storeDir, filename) {
    if (FileSystemEntity.typeSync("$storeDir/$filename") ==
        FileSystemEntityType.file) {
      return true;
    }
    return false;
  }

  static getFile(String filename) async {
    try {
      final path = await getStorageDir;
      final file = File('$path/musics/$filename.txt');
      String text = await file.readAsString();
      print("read file content from $file: $text");
      return text;
    } catch (e) {
      return false;
    }
  }

  static saveFile(String filename) async {
    final path = await getStorageDir;
    final newPath = await createDir("$path/musics/");
    final file = File('$newPath/$filename.txt');
    String data = "Hello Wold";
    await file.writeAsString(data);
    print("saved to $file");
    return true;
  }

  static Future deleteFolder() async {
    final path = await Utils.getStorageDir;
    var dir = new Directory("$path/musics/");
    dir.deleteSync(recursive: true);
  }

  static Future deleteFile(file) async {
    var dir = new File("$file");
    dir.deleteSync(recursive: true);
  }

  static Future<String> createDir(String path) async {
    print("create Path: $path");
    var data = path;
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      await Directory(path).create(recursive: true)
          // The created directory is returned as a Future.
          .then((Directory directory) {
        data = directory.path;
        print("created Path: $path");
      });
    }
    return data;
  }

  static deleteTempFiles(String directory) async {
    String appDir = Constant.app_dir;
    String tempDir = Constant.temp_dir;
    final path = await getStorageDir;
    var dir = new Directory('$path/$appDir/$tempDir/$directory');
    if (await dir.exists()) {
      dir.deleteSync(recursive: true);
    }
  }

  static Future<String> createTemp(String directory) async {
    String appDir = Constant.app_dir;
    String tempDir = Constant.temp_dir;
    final path = await getStorageDir;

    String data = "$path/$appDir/$tempDir/$directory";
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      await Directory(path).create()
          // The created directory is returned as a Future.
          .then((Directory directory) {
        data = directory.path;
      });
    }
    print("created path: $data");
    return data;
  }

  static launchURL(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      MyToast.showToast(context, LocalText.of(context).load("link_error"));
    }
  }

  static length(data) {
    return data.split(",").length;
  }

  static last(data) {
    var arr = data.split(",");
    return arr[arr.length - 1];
  }

  static getImages(data) {
    var arr = [data];
    if (data.contains(',')) {
      arr = data.split(",");
    }
    return arr;
  }

  static removeLast(data) {
    var arr = [data];
    if (data.contains(',')) {
      arr = data.split(",");
      arr.removeAt(arr.length - 1);
    }
    return arr.join(',');
  }

  static remove(data, index) {
    var arr = [data];
    if (data.contains(',')) {
      arr = data.split(",");
      arr.removeAt(index);
    }
    return arr.join(',');
  }

  static arrayRemove(data, index) {
    data.removeAt(index);
    return data;
  }

  static truncate(text, length, suffix) {
    if (text.length > length) {
      return text.substring(0, length) + suffix;
    } else {
      return text;
    }
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  //only available in my api
  static String image(String image,
      {width: "480", height: "425", cropRatio: "6:3.5"}) {
    String link =
        "${Constant.imagePath}$image${Constant.imageFormat}w$width,h$height,cr$cropRatio";
    return encodeMessage(link);
  }

  static String httpLink(inputLink) {
    String link;
    try {
      link = inputLink.replaceAll("https:", "http:");
    } catch (e) {
      link = "$inputLink";
    }
    return link;
  }

  static obfuscate(text) {
    String leading = "";
    int lent = text.length - 3;
    for (int i = 0; i < lent; i++) {
      leading += "*";
    }
    return leading + text.substring(text.length - 3);
  }

  static bool isSuccess(dynamic value) {
    print("checking $value");
    if (value == true) return true;
    bool success;
    try {
      success = value['success'];
    } catch (e) {
      success = true;
    }
    print("checking result: $success");
    return success;
  }

  static viewImages(BuildContext context, List<dynamic> images, int index) {
    PageController _controller =
        PageController(initialPage: index, keepPage: false);
    Navigator.of(context, rootNavigator: true).push(
      new MaterialPageRoute<bool>(
        fullscreenDialog: false,
        builder: (BuildContext context) => PageView.builder(
          controller: _controller,
          itemBuilder: (context, position) {
            return Material(
              type: MaterialType.transparency,
              child: Stack(
                alignment: FractionalOffset.bottomCenter,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: Utils.httpLink(images[position]['src']),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => SpinKitDoubleBounce(
                        color:
                            appTheme.AppColors.purpleMaterial.withOpacity(.3)),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  images[position]['title'] != null
                      ? Container(
                          child: Text(
                            images[position]['title'],
                            style:
                                TextStyle(color: Colors.white, fontSize: 23.0),
                          ),
                          width: double.infinity,
                        )
                      : Container(),
                ],
              ),
            );
          },
          itemCount: images.length,
        ),
      ),
    );
  }

  static viewImages2(
      BuildContext context, List<String> images, int index, String username) {
    PageController _controller =
        PageController(initialPage: index, keepPage: false);
    Navigator.of(context, rootNavigator: true).push(
      new MaterialPageRoute<bool>(
        fullscreenDialog: false,
        builder: (BuildContext context) => PageView.builder(
          controller: _controller,
          itemBuilder: (context, position) {
            return Material(
              type: MaterialType.transparency,
              child: Stack(
                alignment: FractionalOffset.bottomCenter,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: Utils.httpLink(images[position]),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => SpinKitDoubleBounce(
                        color:
                            appTheme.AppColors.purpleMaterial.withOpacity(.3)),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  Container(
                    child: Text(
                      "$username",
                      style: TextStyle(color: Colors.white, fontSize: 23.0),
                    ),
                    width: double.infinity,
                  ),
                ],
              ),
            );
          },
          itemCount: images.length,
        ),
      ),
    );
  }

  static viewImg(BuildContext context, String image, String username) {
    Navigator.of(context, rootNavigator: true).push(
      new MaterialPageRoute<bool>(
        fullscreenDialog: false,
        builder: (BuildContext context) {
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              alignment: FractionalOffset.bottomCenter,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: Utils.httpLink(image),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => SpinKitDoubleBounce(
                      color: appTheme.AppColors.purpleMaterial.withOpacity(.3)),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                Container(
                  child: Text(
                    "$username",
                    style: TextStyle(color: Colors.white, fontSize: 23.0),
                  ),
                  width: double.infinity,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static openSingleImage(BuildContext context, data) {
    data['username'] = data['title'];
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewPage(
            data: data,
          ),
        ));
  }

  static openMultipleImages(BuildContext context, data) {
    data['username'] = data['title'];
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewPage(
            data: data,
          ),
        ));
  }

  static viewImageS(BuildContext context, List<dynamic> images, int index,
      {bool isFave = false}) {
    PageController _controller =
        PageController(initialPage: index, keepPage: false);
    Navigator.of(context, rootNavigator: true).push(
      new MaterialPageRoute<bool>(
        fullscreenDialog: false,
        builder: (BuildContext context) {
          List<Widget> widgetData = [];
          for (int index = 0; index < images.length; index++) {
            if (!isFave) images[index]['username'] = images[index]['title'];
            widgetData.add(ImageViewPage(data: images[index]));
          }
          return PageView(
            children: widgetData,
            controller: _controller,
          );
        },
      ),
    );
  }

  static openWidget(BuildContext context, Widget widget) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => widget),
    );
  }

  static decodeMessage(data) {
    return Uri.decodeFull(data);
  }

  static encodeMessage(data) {
    return Uri.encodeFull(data);
  }

  static validateMessage(data) {
    List<String> msgDate = data["time"].split(' ');
    List<String> splitDate = msgDate[0].split('-');
    List<String> splitTime = msgDate[1].split(':');

    int year = int.parse(splitDate[0]),
        month = int.parse(splitDate[1]),
        day = int.parse(splitDate[2]),
        hour = int.parse(splitTime[0]),
        min = int.parse(splitTime[1]),
        sec = int.tryParse(splitTime[2]) ?? 00;
    data["time"] = DateTime(year, month, day, hour, min, sec).toString();
    data["msg_to"] = data['userid'];
    data["message"] = Utils.encodeMessage(data['message']);
    return data;
  }

  static dateIs(time) {
    DateTime dateToCheck = DateTime.parse(time).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    if (aDate == today) {
      return "Today";
    } else if (aDate == yesterday) {
      return "Yesterday";
    } else {
      return "${_monthNames[dateToCheck.month - 1]} ${dateToCheck.day}, ${dateToCheck.year}";
    }
  }

  static formatNum(numberToFormat) {
    return NumberFormat.compact().format(numberToFormat);
  }

  static dateAgo(time) {
    DateTime dateToCheck = DateTime.parse(time).toLocal();
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day).toLocal();
    final yesterday = DateTime(now.year, now.month, now.day - 1).toLocal();

    final aDate = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day)
        .toLocal();
    if (aDate == today) {
      int hour =
          dateToCheck.hour > 12 ? dateToCheck.hour - 12 : dateToCheck.hour;
      String tx = dateToCheck.hour > 12 ? "pm" : "am";
      String px = dateToCheck.minute < 10 ? "0" : "";
      return "$hour:$px${dateToCheck.minute} $tx";
    } else if (aDate == yesterday) {
      return "Yesterday";
    } else {
      return "${dateToCheck.month}/${dateToCheck.day}/${dateToCheck.year}";
    }
  }

  static timeAgo(time) {
    DateTime dateToCheck = DateTime.parse(time).toLocal();
    int hour = dateToCheck.hour > 12 ? dateToCheck.hour - 12 : dateToCheck.hour;
    String tx = dateToCheck.hour > 12 ? "pm" : "am";
    String px = dateToCheck.minute < 10 ? "0" : "";
    return "$hour:$px${dateToCheck.minute} $tx";
  }

  static getFormattedDate(DateTime date,
      {preformattedDate: false, hideYear: false, timeOnly: false}) {
    final day = date.day.toString();
    final month = _monthNames[date.month - 1].toString();
    final year = date.year.toString();
    final hours = date.hour.toString();
    var minutes = date.minute.toString();
    if (date.minute < 10) {
      // Adding leading zero to minutes
      minutes = "0$minutes";
    }
    if (preformattedDate) {
      // 10:20
      if (timeOnly) {
        return '$hours:$minutes';
      }
      // Today at 10:20
      // Yesterday at 10:20
      return '$preformattedDate at $hours:$minutes';
    }
    if (hideYear) {
      //10:20
      if (timeOnly) {
        return '${date.day}/${date.month} $hours:$minutes';
      }
      // 10. January at 10:20
      return '$day. $month at $hours:$minutes';
    }
    //10/01/2017
    if (timeOnly) {
      return '${date.day}/${date.month}/${date.year}';
    }
    // 10. January 2017. at 10:20
    return '$day. $month $year. at $hours:$minutes';
  }

  static timeAgoFull(DateTime date, {list: false}) {
    final now = DateTime.now().toLocal();

    final todayS =
        DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second)
            .toLocal();
    final today = DateTime(now.year, now.month, now.day).toLocal();
    final yesterday = DateTime(now.year, now.month, now.day - 1).toLocal();
    final seconds = ((todayS.millisecondsSinceEpoch -
                date.toLocal().millisecondsSinceEpoch) /
            1000)
        .round();

    final minutes = (seconds / 60).round();
    final hours = (minutes / 60).round();
    final isToday = today == date.toLocal();
    final isYesterday = yesterday == date.toLocal();
    final isThisYear = today.year == date.toLocal().year;

    if (seconds < 5) {
      return 'now';
    } else if (seconds < 60) {
      return '$seconds sec ago';
    } else if (seconds < 90) {
      return 'a min ago';
    } else if (minutes < 60) {
      return '$minutes mins ago';
    } else if (hours < 2) {
      return '$hours hour ago';
    } else if (hours < 24) {
      return '$hours hours ago';
    } else if (isToday) {
      return getFormattedDate(date.toLocal(),
          preformattedDate: 'Today', timeOnly: list); // Today at 10:20
    } else if (isYesterday) {
      return getFormattedDate(date.toLocal(),
          preformattedDate: 'Yest', timeOnly: list); // Yesterday at 10:20
    } else if (isThisYear) {
      return getFormattedDate(date.toLocal(),
          preformattedDate: false,
          hideYear: true,
          timeOnly: list); // 10. January at 10:20
    }
    return getFormattedDate(date.toLocal(),
        timeOnly: list); // 10. January 2017. at 10:20
  }

  static void syncSales(DatabaseHelper db, BuildContext context) async {
    NetworkUtil _netUtil = new NetworkUtil();
    List<Map<String, dynamic>> sales = await db.getSales();
    for (int index = 0; index < sales.length; index++) {
      var sale = sales[index];
      await _netUtil
          .post("${Constant.syncSaleRequest}", context, body: sale)
          .then((value) async {
        if (value['success'] == true) {
          await db.deleteSale('${sale['sales_number']}');
        }
      }).catchError((error) {});
    }
  }
}

class ImageViewPage extends StatefulWidget {
  ImageViewPage({Key key, this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  _ImageViewPageState createState() => new _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  bool imageIsInFav = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {}

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        alignment: FractionalOffset.bottomCenter,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: Utils.httpLink(widget.data['src']),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            placeholder: (context, url) => SpinKitDoubleBounce(
                color: appTheme.AppColors.purpleMaterial.withOpacity(.3)),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(
                    "${widget.data['username']}",
                    style: TextStyle(color: Colors.white, fontSize: 23.0),
                  ),
                ),
              ],
            ),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
