import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class DioClient {
  static Dio create() {
    return Dio(BaseOptions(
      headers: {
        'User-Agent': AppConstants.userAgent,
      },
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      followRedirects: true,
      validateStatus: (status) => status! < 500,
    ));
  }
}

