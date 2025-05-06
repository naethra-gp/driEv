/* ===============================================================
| Project : driEV
| Page    : CONNECTION.DART
| Date    :
| DESC    : THIS IS MAIN CONNECTION FILE
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../app_config/app_constants.dart';
import '../app_storages/secure_storage.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

class Connection {
  static const int _timeoutDuration = 30; // seconds
  static const int _maxRetries = 3;

  final AlertServices alertService = AlertServices();
  final SecureStorage _secureStorage = SecureStorage();

  Map<String, String> get _baseHeader => {
        'Content-Type': 'application/json',
      };

  Map<String, String> get _authHeader => {
        ..._baseHeader,
        'Authorization': "Bearer ${_secureStorage.getToken().toString()}",
      };

  /*
    * GLOBAL EXCEPTION METHOD
  */
  void customException(dynamic e, {String? customMessage}) {
    alertService.hideLoading();
    Fluttertoast.cancel();
    String tryAgain = "Please try again later.";

    if (e is SocketException) {
      String msg = 'No Internet Connection. $tryAgain';
      alertService.errorToast(msg);
    } else if (e is TimeoutException) {
      String msg = "Oops! it's taking a little longer than expected. $tryAgain";
      alertService.errorToast(msg);
    } else if (e is FormatException) {
      String msg = 'Invalid response format. $tryAgain';
      alertService.errorToast(msg);
    } else if (e is HttpException) {
      String msg = 'Server error occurred. $tryAgain';
      alertService.errorToast(msg);
    } else {
      String msg =
          customMessage ?? 'Something went wrong. Please try again in a bit.';
      alertService.errorToast(msg);
    }
  }

  Future<dynamic> _handleResponse(Response response,
      {bool showError = true}) async {
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
    } else if (response.statusCode == 401) {
      alertService.errorToast("Session expired. Please login again.");
      gotoLogin();
      return null;
    } else if (response.statusCode == 404) {
      if (showError) {
        final result = json.decode(response.body);
        alertService.errorToast(result['message'].toString());
      }
      return json.decode(response.body);
    } else {
      if (showError) {
        final result = json.decode(response.body);
        alertService.errorToast(
            "${response.statusCode}: ${result['message'].toString()}");
      }
      return null;
    }
  }

  Future<Response> _retryRequest(Future<Response> Function() request,
      {int retryCount = 0}) async {
    try {
      return await request();
    } catch (e) {
      if (retryCount < _maxRetries) {
        await Future.delayed(Duration(seconds: 1 * (retryCount + 1)));
        return _retryRequest(request, retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  Future<http.StreamedResponse> _retryMultipartRequest(
      Future<http.StreamedResponse> Function() request,
      {int retryCount = 0}) async {
    try {
      return await request();
    } catch (e) {
      if (retryCount < _maxRetries) {
        await Future.delayed(Duration(seconds: 1 * (retryCount + 1)));
        return _retryMultipartRequest(request, retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  /*
  * SERVICE NAME: getWithoutToken
  * DESC: Global GET Method Without Token
  * METHOD: GET
  * Params: url
  */
  Future<dynamic> getWithoutToken(String url) async {
    final trace = FirebasePerformance.instance.newTrace("get_without_token");
    await trace.start();

    try {
      if (!Uri.parse(url).isAbsolute) {
        throw const FormatException('Invalid URL format');
      }

      debugPrint("[GET] => API: $url");
      final response = await _retryRequest(() => http
          .get(
            Uri.parse(url),
            headers: _baseHeader,
          )
          .timeout(const Duration(seconds: _timeoutDuration)));

      return await _handleResponse(response);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      customException(e);
      return null;
    } finally {
      await trace.stop();
      debugPrint('--- API request completed ---');
    }
  }

  /*
  * SERVICE NAME: postWithoutToken
  * DESC: Global POST Method Without Token
  * METHOD: POST
  * Params: url, Request Params
  */
  Future<dynamic> postWithoutToken(String url, dynamic request) async {
    final trace = FirebasePerformance.instance.newTrace("post_without_token");
    await trace.start();

    try {
      if (!Uri.parse(url).isAbsolute) {
        throw const FormatException('Invalid URL format');
      }

      debugPrint("[POST] =>  API: $url");
      final response = await _retryRequest(() => http
          .post(
            Uri.parse(url),
            headers: _baseHeader,
            body: jsonEncode(request),
          )
          .timeout(const Duration(seconds: _timeoutDuration)));

      return await _handleResponse(response);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      customException(e);
      return null;
    } finally {
      await trace.stop();
      debugPrint('--- API request completed ---');
    }
  }

  Future<dynamic> postWithToken(String url, dynamic request,
      [bool? error]) async {
    final trace = FirebasePerformance.instance.newTrace("post_with_token");
    await trace.start();

    try {
      if (!Uri.parse(url).isAbsolute) {
        throw const FormatException('Invalid URL format');
      }

      debugPrint("[POST] =>  API: $url");
      final response = await _retryRequest(() => http
          .post(
            Uri.parse(url),
            headers: _authHeader,
            body: jsonEncode(request),
          )
          .timeout(const Duration(seconds: _timeoutDuration)));

      return await _handleResponse(response, showError: error != true);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      customException(e);
      return null;
    } finally {
      await trace.stop();
      debugPrint('--- API Request Completed ---');
    }
  }

  Future<dynamic> getWithToken(String url, [bool? error]) async {
    final trace = FirebasePerformance.instance.newTrace("get_with_token");
    await trace.start();

    try {
      if (!Uri.parse(url).isAbsolute) {
        throw const FormatException('Invalid URL format');
      }

      debugPrint("[GET] =>  API: $url");
      final response = await _retryRequest(() => http
          .get(
            Uri.parse(url),
            headers: _authHeader,
          )
          .timeout(const Duration(seconds: _timeoutDuration)));

      return await _handleResponse(response, showError: error != true);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      if (error != true) {
        customException(e);
      }
      return null;
    } finally {
      await trace.stop();
      debugPrint('--- API Request Completed ---');
    }
  }

  void gotoLogin() {
    var ctx = Constants.navigatorKey.currentState!.overlay!.context;
    Navigator.pushNamedAndRemoveUntil(ctx, "login", (r) => false);
  }

  Future<dynamic> postWithTokenAlert(String url, dynamic request,
      [bool? error]) async {
    final trace =
        FirebasePerformance.instance.newTrace("post_with_token_alert");
    await trace.start();

    try {
      if (!Uri.parse(url).isAbsolute) {
        throw const FormatException('Invalid URL format');
      }

      debugPrint("[POST] =>  API: $url");
      final response = await _retryRequest(() => http
          .post(
            Uri.parse(url),
            headers: _authHeader,
            body: jsonEncode(request),
          )
          .timeout(const Duration(seconds: _timeoutDuration)));

      return await _handleResponse(response, showError: error != true);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      customException(e);
      return null;
    } finally {
      await trace.stop();
      debugPrint('--- API Request Completed ---');
    }
  }

  Future<dynamic> getWithTokenAlert(String url, [bool? error]) async {
    final trace = FirebasePerformance.instance.newTrace("get_with_token_alert");
    await trace.start();

    try {
      if (!Uri.parse(url).isAbsolute) {
        throw const FormatException('Invalid URL format');
      }

      debugPrint("[GET] =>  API: $url");
      final response = await _retryRequest(() => http
          .get(
            Uri.parse(url),
            headers: _authHeader,
          )
          .timeout(const Duration(seconds: _timeoutDuration)));

      return await _handleResponse(response, showError: error != true);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      if (error != true) {
        customException(e);
      }
      return null;
    } finally {
      await trace.stop();
      debugPrint('--- API Request Completed ---');
    }
  }

  Future<dynamic> uploadFile(String url, dynamic filePath) async {
    final trace = FirebasePerformance.instance.newTrace("upload_file");
    await trace.start();

    try {
      if (!Uri.parse(url).isAbsolute) {
        throw const FormatException('Invalid URL format');
      }

      debugPrint("UPLOADING API: $url");
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(_authHeader);
      request.files.add(
        await http.MultipartFile.fromPath('image', filePath.path),
      );

      final response = await _retryMultipartRequest(() =>
          request.send().timeout(const Duration(seconds: _timeoutDuration)));

      if (response.statusCode == 200) {
        return await response.stream.bytesToString();
      } else {
        alertService
            .errorToast('Failed to upload file: ${response.reasonPhrase}');
        return null;
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      customException(e);
      return null;
    } finally {
      await trace.stop();
      debugPrint('--- API Request Completed ---');
    }
  }

  Future<dynamic> reUploadDocument(
      String url, dynamic filePath, dynamic user) async {
    final trace = FirebasePerformance.instance.newTrace("reupload_document");
    await trace.start();

    try {
      if (!Uri.parse(url).isAbsolute) {
        throw const FormatException('Invalid URL format');
      }

      debugPrint("RE UPLOADING API: $url");
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(_authHeader);
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath.path),
      );
      request.fields.addAll({'user': jsonEncode(user)});

      final response = await _retryMultipartRequest(() =>
          request.send().timeout(const Duration(seconds: _timeoutDuration)));
      final response2 = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return response2.body;
      } else {
        String msg = 'Failed to upload file: ${response.reasonPhrase}';
        alertService.errorToast(msg);
        return null;
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      customException(e);
      return null;
    } finally {
      await trace.stop();
      debugPrint('--- API request completed ---');
    }
  }
}
