
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class CustomAPI{
  final String baseUrl;
  final LoggingInterceptor? loggingInterceptor;
  final int? connectTimeout;
  final int? receiveTimeout;
  final int? maxRedirects;
  
  Dio dio = Dio();

  CustomAPI(
    this.baseUrl,
    Dio? dioC, {
    this.loggingInterceptor,
     this.connectTimeout,
     this.receiveTimeout,
     this.maxRedirects
  }) {
    dio = dioC ?? Dio();
    dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout =  Duration(seconds: connectTimeout??5)
      ..options.receiveTimeout =  Duration(seconds: receiveTimeout??5)
      ..options.maxRedirects = maxRedirects??5
      ..httpClientAdapter
      ..options.headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
    dio.interceptors.add(loggingInterceptor!);
  }

  Future<ApiResponse> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    String? apiUsername,
    String? apiPassword,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await dio.get(
        uri,
        queryParameters: queryParameters,
        options: Options(headers: {'Authorization': 'Basic ${base64.encode(utf8.encode('$apiUsername:$apiPassword'))}'}),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse.withSuccess(response);
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      return ApiResponse.withError(e);
    }
  }

  Future<ApiResponse> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    String? apiUsername,
    String? apiPassword,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: {'Authorization': 'Basic ${base64.encode(utf8.encode('$apiUsername:$apiPassword'))}'}),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse.withSuccess(response);
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      return ApiResponse.withError(e);
    }
  }

  Future<ApiResponse> put(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    String? apiUsername,
    String? apiPassword,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: {'Authorization': 'Basic ${base64.encode(utf8.encode('$apiUsername:$apiPassword'))}'}),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse.withSuccess(response);
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      return ApiResponse.withError(e);
    }
  }

  Future<ApiResponse> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    String? apiUsername,
    String? apiPassword,
    CancelToken? cancelToken,
  }) async {
    try {
      Response response = await dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: {'Authorization': 'Basic ${base64.encode(utf8.encode('$apiUsername:$apiPassword'))}'}),
        cancelToken: cancelToken,
      );
      return ApiResponse.withSuccess(response);
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      return ApiResponse.withError(e);
    }
  }
}


class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print("--> ${options.method} ${options.path}");
    print("Headers: ${options.headers.toString()}");
    print("<-- END HTTP");

    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    print(
        "<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}");

    String responseAsString = response.data.toString();

    if (responseAsString.length > maxCharactersPerLine) {
      int iterations = (responseAsString.length / maxCharactersPerLine).floor();
      for (int i = 0; i <= iterations; i++) {
        int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
        if (endingIndex > responseAsString.length) {
          endingIndex = responseAsString.length;
        }
        print(
            responseAsString.substring(i * maxCharactersPerLine, endingIndex));
      }
    } else {
      print(response.data);
    }
    print("<-- END HTTP");
    return super.onResponse(response, handler);
  }

  @override
  // ignore: deprecated_member_use
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    print(
        "ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");
    return super.onError(err, handler);
  }
}

class ApiResponse {
  final Response? response;
  final dynamic error;

  ApiResponse(this.response, this.error);

  ApiResponse.withError(dynamic errorValue)
      : response = null,
        error = errorValue;

  ApiResponse.withSuccess(Response responseValue)
      : response = responseValue,
        error = null;
}
