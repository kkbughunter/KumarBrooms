import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

Future<void> configurePlatformClient(Dio dio) async {
  final directory = await getApplicationSupportDirectory();
  final cookieJar = PersistCookieJar(
    ignoreExpires: false,
    storage: FileStorage('${directory.path}/.auth_cookies/'),
  );
  dio.interceptors.add(CookieManager(cookieJar));
}
