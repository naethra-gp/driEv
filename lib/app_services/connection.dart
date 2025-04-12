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

class Connection {
  final header = {'Content-Type': 'application/json'};
  AlertServices alertService = AlertServices();

  /*
    * GLOBAL EXCEPTION METHOD
  */
  customException(e) {
    alertService.hideLoading();
    Fluttertoast.cancel();
    String tryAgain = "Please try again later.";
    if (e is SocketException) {
      String msg = 'No Internet Connection. $tryAgain';
      alertService.errorToast(msg);
    } else if (e is TimeoutException) {
      String msg = "Oops! it's taking a little longer than expected. $tryAgain";
      alertService.errorToast(msg);
    } else {
      String msg = 'Something went wrong. Please try again in a bit.';
      alertService.errorToast(msg);
    }
  }

  /*
  * SERVICE NAME: getWithoutToken
  * DESC: Global GET Method Without Token
  * METHOD: GET
  * Params: url
  */
  getWithoutToken(String url) async {
    try {
      debugPrint("[GET] => API: $url");
      var response = await http.get(Uri.parse(url), headers: header);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final result = json.decode(response.body);
        String msg = "${response.statusCode}: ${result['message'].toString()}";
        alertService.errorToast(msg);
      }
    } catch (e) {
      customException(e);
    } finally {
      debugPrint('--- API request completed ---');
    }
  }

  /*
  * SERVICE NAME: postWithoutToken
  * DESC: Global POST Method Without Token
  * METHOD: POST
  * Params: url, Request Params
  */
  postWithoutToken(String url, request) async {
    try {
      debugPrint("[POST] =>  API: $url");
      var response = await http.post(
        Uri.parse(url),
        headers: header,
        body: jsonEncode(request),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final result = json.decode(response.body);
        String msg = "${response.statusCode}: ${result['message'].toString()}";
        alertService.errorToast(msg);
      }
    } catch (e) {
      customException(e);
    } finally {
      debugPrint('--- API request completed ---');
    }
  }

  postWithToken(String url, request, [error]) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
      debugPrint("[POST] =>  API: $url");
      Response response = await http.post(
        Uri.parse(url),
        headers: header,
        body: jsonEncode(request),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        if (error != null) {
          gotoLogin(); // goto LOGIN PAGE
          return json.decode(response.body);
        } else {
          var result = json.decode(response.body);
          alertService.errorToast(result['message'].toString());
        }
      } else {
        var result = json.decode(response.body);
        alertService.errorToast(result['message'].toString());
      }
    } catch (e) {
      customException(e);
    } finally {
      debugPrint('--- API Request Completed ---');
    }
  }

  getWithToken(String url, [error]) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
      debugPrint("[GET] =>  API: $url");
      var response = await http.get(
        Uri.parse(url),
        headers: header,
      );
      if (response.statusCode == 200) {
        return json
            .decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      } else if (response.statusCode == 401) {
        alertService.errorToast("Unauthorized");
        gotoLogin();
        return null;
      } else {
        if (error == null) {
          var result = json.decode(response.body);
          alertService.errorToast(
              "${response.statusCode}: ${result['message'].toString()}");
        }
      }
    } catch (e) {
      if (error == null) {
        customException(e);
      }
    } finally {
      debugPrint('--- API Request Completed ---');
    }
  }

  gotoLogin() {
    var ctx = Constants.navigatorKey.currentState!.overlay!.context;
    Navigator.pushNamedAndRemoveUntil(ctx, "login", (r) => false);
  }

  postWithTokenAlert(String url, request, [error]) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
      debugPrint("[POST] =>  API: $url");
      var response = await http.post(
        Uri.parse(url),
        headers: header,
        body: jsonEncode(request),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        if (error != null) {
          gotoLogin();
          return json.decode(response.body);
        } else {
          var result = json.decode(response.body);
          return result;
        }
      } else {
        var result = json.decode(response.body);
        alertService.errorToast(result['message'].toString());
      }
    } catch (e) {
      customException(e);
    } finally {
      debugPrint('--- API Request Completed ---');
    }
  }

  getWithTokenAlert(String url, [error]) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
      debugPrint("[GET] =>  API: $url");
      var response = await http.get(
        Uri.parse(url),
        headers: header,
      );
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(
          response.bodyBytes,
          allowMalformed: true,
        ));
      } else if (response.statusCode == 401) {
        alertService.errorToast("Unauthorized");
        gotoLogin();
        return null;
      } else {
        if (error == null) {
          final decodedResponse = utf8.decode(response.bodyBytes);
          final data = jsonDecode(decodedResponse);
          return data;
        }
      }
    } catch (e) {
      if (error == null) {
        customException(e);
      }
    } finally {
      debugPrint('--- API Request Completed ---');
    }
  }

  uploadFile(String url, filePath) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
      debugPrint("UPLOADING API: $url");
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(header);
      request.files.add(
        await http.MultipartFile.fromPath('image', filePath.path),
      );
      var response = await request.send();
      if (response.statusCode == 200) {
        return await response.stream.bytesToString();
      } else {
        alertService
            .errorToast('Failed to upload file: ${response.reasonPhrase}');
      }
    } catch (e) {
      customException(e);
    } finally {
      debugPrint('--- API Request Completed ---');
    }
  }

  reUploadDocument(String url, filePath, user) async {
    SecureStorage secureStorage = SecureStorage();
    String token = secureStorage.getToken().toString();
    final header = {'Authorization': "Bearer $token"};
    try {
      debugPrint("RE UPLOADING API: $url");
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(header);
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath.path),
      );
      Map<String, String> fields = {'user': jsonEncode(user)};
      request.fields.addAll(fields);
      final response = await request.send();
      final response2 = await http.Response.fromStream(response);
      if (response.statusCode == 200) {
        return response2.body;
      } else {
        String msg = 'Failed to upload file: ${response.reasonPhrase}';
        alertService.errorToast(msg);
      }
    } catch (e) {
      customException(e);
    } finally {
      debugPrint('--- API request completed ---');
    }

    // try {
    //   var request = http.MultipartRequest('POST', Uri.parse(url));
    //   request.headers.addAll(header);
    //   request.files.add(
    //     await http.MultipartFile.fromPath('file', filePath.path),
    //   );
    //   Map<String, String> fields = {
    //     'user': jsonEncode(user),
    //   };
    //   request.fields.addAll(fields);
    //   var response = await request.send();
    //   if (response.statusCode == 200) {
    //     return await response.stream.bytesToString();
    //   } else {
    //     alertService
    //         .errorToast('Failed to upload file: ${response.reasonPhrase}');
    //   }
    // } on FileSystemException catch (e) {
    //   alertService
    //       .errorToast('Something went wrong. Please try again in a bit.');
    // } catch (e) {
    //   if (e is SocketException) {
    //     alertService
    //         .errorToast('No Internet Connection. Please try again later.');
    //   } else if (e is TimeoutException) {
    //     alertService.errorToast(
    //         'Oops! it\'s taking a little longer than expected. Please try again soon.');
    //   } else {
    //     alertService
    //         .errorToast('Something went wrong. Please try again in a bit.');
    //   }
    // } finally {
    //   debugPrint('API request completed');
    // }
  }
}
