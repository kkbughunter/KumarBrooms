import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

Future<void> configurePlatformClient(Dio dio) async {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}
