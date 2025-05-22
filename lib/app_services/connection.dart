/* ===============================================================
| Project : driEV
| Page    : CONNECTION.DART
| Date    :
| DESC    : THIS IS MAIN CONNECTION FILE
*  ===============================================================*/

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:driev/app_config/app_logs.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../app_config/app_constants.dart';
import '../app_storages/secure_storage.dart';

class Connection {
  final AlertServices alertService = AlertServices();
  final SecureStorage _secureStorage = SecureStorage();

  Map<String, String> get _baseHeader => {'Content-Type': 'application/json'};

  Map<String, String> get _authHeader => {
        ..._baseHeader,
        'Authorization': "Bearer ${_secureStorage.getToken().toString()}",
      };
  void finalDebug() {
    if (!kReleaseMode) {
      debugPrint('===> API CALL COMPLETED <===');
    }
  }

  // Common error handling
  void customException(dynamic e, {String? customMessage}) {
    alertService.hideLoading();
    Fluttertoast.cancel();
    String tryAgain = "Please try again later.";

    String msg = switch (e) {
      SocketException() => 'No Internet Connection. $tryAgain',
      TimeoutException() =>
        "Oops! it's taking a little longer than expected. $tryAgain",
      FormatException() => 'Invalid response format. $tryAgain',
      HttpException() => 'Server error occurred. $tryAgain',
      _ => customMessage ?? 'Something went wrong. Please try again in a bit.',
    };

    alertService.errorToast(msg);
  }

  // Common response handling
  Future<dynamic> _handleResponse(Response response,
      {bool showError = true}) async {
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
    }

    if (response.statusCode == 401) {
      alertService.errorToast("Session expired. Please login again.");
      gotoLogin();
      return null;
    }

    if (showError) {
      final result = json.decode(response.body);
      alertService.errorToast(
          "${response.statusCode}: ${result['message'].toString()}");
    }

    return response.statusCode == 404 ? json.decode(response.body) : null;
  }

  // Common request execution with performance tracking
  Future<dynamic> _executeRequest(
    Future<Response> Function() request,
    String traceName,
    String method,
    String url, {
    dynamic requestBody,
    bool showError = true,
  }) async {
    final trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.start();

    try {
      final response = await request();

      printServiceLogs(
        method,
        url,
        request: requestBody != null ? jsonEncode(requestBody) : null,
        response: json.decode(response.body),
      );

      return await _handleResponse(response, showError: showError);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      if (showError) customException(e);
      return null;
    } finally {
      await trace.stop();
      finalDebug();
    }
  }

  // Navigation
  void gotoLogin() {
    var ctx = Constants.navigatorKey.currentState!.overlay!.context;
    Navigator.pushNamedAndRemoveUntil(ctx, "login", (r) => false);
  }

  // API Methods
  Future<dynamic> getWithoutToken(String url) async {
    return _executeRequest(
      () => http.get(Uri.parse(url), headers: _baseHeader),
      "get_without_token",
      'GET WITHOUT TOKEN',
      url,
    );
  }

  Future<dynamic> postWithoutToken(String url, dynamic request) async {
    return _executeRequest(
      () => http.post(
        Uri.parse(url),
        headers: _baseHeader,
        body: jsonEncode(request),
      ),
      "post_without_token",
      'POST WITHOUT TOKEN',
      url,
      requestBody: request,
    );
  }

  Future<dynamic> postWithToken(String url, dynamic request,
      [bool? error]) async {
    return _executeRequest(
      () => http.post(
        Uri.parse(url),
        headers: _authHeader,
        body: jsonEncode(request),
      ),
      "post_with_token",
      'POST WITH TOKEN',
      url,
      requestBody: request,
      showError: error != true,
    );
  }

  Future<dynamic> getWithToken(String url, [bool? error]) async {
    return _executeRequest(
      () => http.get(Uri.parse(url), headers: _authHeader),
      "get_with_token",
      'GET WITH TOKEN',
      url,
      showError: error != true,
    );
  }

  Future<dynamic> postWithTokenAlert(String url, dynamic request,
      [bool? error]) async {
    return _executeRequest(
      () => http.post(
        Uri.parse(url),
        headers: _authHeader,
        body: jsonEncode(request),
      ),
      "post_with_token_alert",
      'POST WITH TOKEN',
      url,
      requestBody: request,
      showError: error != true,
    );
  }

  Future<dynamic> getWithTokenAlert(String url, [bool? error]) async {
    return _executeRequest(
      () => http.get(Uri.parse(url), headers: _authHeader),
      "get_with_token_alert",
      'GET WITH TOKEN ALERT',
      url,
      showError: error != true,
    );
  }

  // File upload methods
  Future<dynamic> _handleFileUpload(
    Future<http.StreamedResponse> Function() uploadRequest,
    String traceName,
    String url,
  ) async {
    final trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.start();

    try {
      final response = await uploadRequest();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        printServiceLogs('UPLOAD FILE', url, response: responseBody);
        return responseBody;
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
      finalDebug();
    }
  }

  Future<dynamic> uploadFile(String url, dynamic filePath) async {
    return _handleFileUpload(
      () async {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll(_authHeader);
        request.files.add(
          await http.MultipartFile.fromPath('image', filePath.path),
        );
        return request.send();
      },
      "upload_file",
      url,
    );
  }

  Future<dynamic> reUploadDocument(
      String url, dynamic filePath, dynamic user) async {
    return _handleFileUpload(
      () async {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll(_authHeader);
        request.files.add(
          await http.MultipartFile.fromPath('file', filePath.path),
        );
        request.fields.addAll({'user': jsonEncode(user)});
        return request.send();
      },
      "reupload_document",
      url,
    );
  }
}
