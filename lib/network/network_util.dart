import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:todays_sales/pages/login/login.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/widgets/Dialogs.dart';

class NetworkUtil {
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil.internal();

  NetworkUtil.internal();

  factory NetworkUtil() => _instance;
  final JsonDecoder _decoder = new JsonDecoder();

  Future<BaseOptions> getOptions({validate = true}) async {
    var authentication = await DatabaseHelper.internal().authentication();
    BaseOptions options = new BaseOptions(
        baseUrl: Constant.api,
        connectTimeout: 15000,
        receiveTimeout: 100000,
        headers: {'Authorization': 'Bearer $authentication'},
        responseType: ResponseType.plain,
        contentType: 'application/json');
    return options;
  }

  Future<dynamic> get(String url, BuildContext context,
      {authorize = true}) async {
    dynamic serverResponse, response;
    BaseOptions options = await getOptions(validate: authorize);
    try {
      Dio dio = new Dio(options);
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        SecurityContext sc = new SecurityContext();
        //file is the path of certificate
//        sc.setTrustedCertificates(file);
        HttpClient httpClient = new HttpClient(context: sc);
        //allow all cert
        httpClient.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return httpClient;
      };

      serverResponse = await dio.get(url);

      print("RESPONSE FROM GET ${serverResponse.statusMessage}");
      //check for connection errors
      if (serverResponse.statusCode < 200 || serverResponse.statusCode > 400) {
        return _decoder
            .convert('{"success":false,"message":"Error Executing Request"}');
      }

      print(serverResponse.data);
      response = _decoder.convert(serverResponse.data);
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        response = '{"success":false,"message":"${e.response.statusMessage}"}';
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.message);
        response =
            _decoder.convert('{"success":false,"message":"' + e.message + '"}');
      }
    } catch (error) {
      return _decoder
          .convert('{"success":false,"message":"Error Executing Request"}');
    }
    return response;
  }

  Future<dynamic> head(String url, BuildContext context) async {
    bool serverResponse = false;
    try {
      BaseOptions options = await getOptions(validate: false);
      Dio dio = new Dio(options);
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        SecurityContext sc = new SecurityContext();
        HttpClient httpClient = new HttpClient(context: sc);
        httpClient.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return httpClient;
      };
      var response = await dio.head(url);
      if (response.statusCode == 200)
        serverResponse = true;
      else
        serverResponse = false;
    } on DioError {
      serverResponse = false;
    }
    return serverResponse;
  }

  Future<dynamic> post(String url, BuildContext context,
      {Map body, authorize = true}) async {
    print("$url");
    dynamic serverResponse, response;
    BaseOptions options = await getOptions(validate: authorize);

    try {
      Dio dio = new Dio(options);
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        SecurityContext sc = new SecurityContext();
        //file is the path of certificate
//        sc.setTrustedCertificates(file);
        HttpClient httpClient = new HttpClient(context: sc);
        //allow all cert
        httpClient.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return httpClient;
      };

      serverResponse = await dio.post(url, data: json.encode(body));
      print("SERVER RESPONSE: $serverResponse");

      //check for connection errors
      if (serverResponse.statusCode < 200 || serverResponse.statusCode > 400) {
        return _decoder
            .convert('{"success":false,"message":"Error Executing Request"}');
      }

      response = _decoder.convert(serverResponse.data);
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.statusCode);
        String dataRes;
        if (401 == e.response.statusCode) {
          var data = _decoder.convert(e.response.data);
          print(data);
          if (data['message'] == '401 token invalid') {
            var dialogs = Dialogs();
            dialogs.infoDialog(context, "Error: Auth changed",
                'You auth key has changed, this happens when you login with your username and password in a different device',
                onPressed: (confirmed) async {
              var db = new DatabaseHelper();
              var pref = await SharedPreferences.getInstance();
              pref.remove(Constant.storesPrefs);
              pref.remove(Constant.salesPrefs);
              pref.remove(Constant.salesStatsPrefs);
              pref.remove(Constant.storeDataPrefs);
              pref.remove(Constant.customersPrefs);
              pref.remove(Constant.agentsPrefs);
              pref.remove(Constant.storeCodePrefs);
              pref.remove(Constant.itemListPrefs);
              pref.remove(Constant.itemsListPrefs);
              await db.deleteUsers();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ));
            });
            return;
          }
        } else if (403 == e.response.statusCode) {
          dataRes = e.response.data;
        } else {
          dataRes = '{"success":false,"message":"${e.response.statusMessage}"}';
        }
        response = _decoder.convert(dataRes);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.message);
        response = _decoder
            .convert('{"success":false,"message":"Error Executing Request"}');
      }
    } catch (error) {
      print(error);
      return _decoder
          .convert('{"success":false,"message":"Error Executing Request"}');
    }
    return response;
  }
}

/// Describes the info of file to upload.
class UploadFileInfo {
  UploadFileInfo(this.file, this.fileName, {ContentType contentType})
      : bytes = null,
        this.contentType = contentType ?? ContentType.binary;

  UploadFileInfo.fromBytes(this.bytes, this.fileName, {ContentType contentType})
      : file = null,
        this.contentType = contentType ?? ContentType.binary;

  /// The file to upload.
  final File file;

  /// The file content
  final List<int> bytes;

  /// The file name which the server will receive.
  final String fileName;

  /// The content-type of the upload file. Default value is `ContentType.binary`
  ContentType contentType;
}
