import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart';

class APIService {
  static final APIService _instance = APIService._internal();
  String masterServer =
      "https://alexisl61.github.io/JackboxUtility/servers.json";
  String? baseEndpoint;
  String? baseAssets;

  // Build factory
  factory APIService() {
    return _instance;
  }

  // Build internal
  APIService._internal();

  // Download game patch
  Future<String> downloadUpdate(
      String updateUri, void Function(double, double) progressCallback) async {
    Dio dio = Dio();
    final response = await dio.downloadUri(
        Uri.parse(updateUri), "./downloads/tmp."+updateUri.split(".").last,
        options: Options(),
        onReceiveProgress: (received, total) {
      progressCallback(received.toInt().toDouble(), total.toInt().toDouble());
    });
    if (response.statusCode == 200) {
      return  "./downloads/tmp."+updateUri.split(".").last;
    } else {
      throw Exception('Failed to download patch');
    }
  }
}
