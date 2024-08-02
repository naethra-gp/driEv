import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../app_config/app_constants.dart';
import '../app_storages/secure_storage.dart';

class Connection {
  final header = {'Content-Type': 'application/json'};
  AlertServices alertService = AlertServices();

  getWithoutToken(String url) async {
    try {
      var response = await http.get(Uri.parse(url), headers: header);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        var result = json.decode(response.body);
        alertService.errorToast(
            "${response.statusCode}: ${result['message'].toString()}");
      }
    } catch (e) {
      if (e is SocketException) {
        alertService
            .errorToast('No Internet Connection. Please try again later.');
      } else if (e is TimeoutException) {
        alertService.errorToast(
            'Oops! it\'s taking a little longer than expected. Please try again soon.');
      } else {
        alertService
            .errorToast('Something went wrong. Please try again in a bit.');
      }
      // alertService.errorToast("Error: ${e.toString()}");
    } finally {
      // print('API request completed');
    }
  }

  postWithoutToken(String url, request) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: header,
        body: jsonEncode(request),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        var result = json.decode(response.body);
        alertService.errorToast(
            "${response.statusCode}: ${result['message'].toString()}");
      }
    } catch (e) {
      if (e is SocketException) {
        alertService
            .errorToast('No Internet Connection. Please try again later.');
      } else if (e is TimeoutException) {
        alertService.errorToast(
            'Oops! it\'s taking a little longer than expected. Please try again soon.');
      } else {
        alertService
            .errorToast('Something went wrong. Please try again in a bit.');
      }
      // alertService.errorToast("Error: ${e.toString()}");
    } finally {
      print('API request completed');
    }
  }

  postWithToken(String url, request, [error]) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
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
          alertService.errorToast(result['message'].toString());
        }
      } else {
        var result = json.decode(response.body);
        alertService.errorToast(result['message'].toString());
      }
    } catch (e) {
      if (e is SocketException) {
        alertService
            .errorToast('No Internet Connection. Please try again later.');
      } else if (e is TimeoutException) {
        alertService.errorToast(
            'Oops! it\'s taking a little longer than expected. Please try again soon.');
      } else {
        alertService
            .errorToast('Something went wrong. Please try again in a bit.');
      }
      // alertService.errorToast("Error: ${e.toString()}");
    } finally {
      print('API request completed');
    }
  }

  getWithToken(String url, [error]) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
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
        if (e is SocketException) {
          alertService
              .errorToast('No Internet Connection. Please try again later.');
        } else if (e is TimeoutException) {
          alertService.errorToast(
              'Oops! it\'s taking a little longer than expected. Please try again soon.');
        } else {
          alertService
              .errorToast('Something went wrong. Please try again in a bit.');
        }
        // alertService.errorToast("Error: ${e.toString()}");
      }
    } finally {
      print('API request completed');
    }
  }

  uploadFile(String url, filePath) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
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
      if (e is SocketException) {
        alertService
            .errorToast('No Internet Connection. Please try again later.');
      } else if (e is TimeoutException) {
        alertService.errorToast(
            'Oops! it\'s taking a little longer than expected. Please try again soon.');
      } else {
        alertService
            .errorToast('Something went wrong. Please try again in a bit.');
      }
      // alertService.errorToast("Error: ${e.toString()}");
    } finally {
      print('API request completed');
      final cacheDir = await getTemporaryDirectory();
      Future.delayed(const Duration(seconds: 2), () {
        if (cacheDir.existsSync()) {
          cacheDir.deleteSync(recursive: true);
        }
      });
    }
  }

  reUploadDocument(String url, filePath, user) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(header);
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath.path),
      );
      Map<String, String> fields = {
        'user': jsonEncode(user),
      };
      request.fields.addAll(fields);
      var response = await request.send();
      if (response.statusCode == 200) {
        return await response.stream.bytesToString();
      } else {
        alertService
            .errorToast('Failed to upload file: ${response.reasonPhrase}');
      }
    } on FileSystemException catch (e) {
      alertService.errorToast('Something went wrong. Please try again in a bit.');
    } catch (e) {
      if (e is SocketException) {
        alertService
            .errorToast('No Internet Connection. Please try again later.');
      } else if (e is TimeoutException) {
        alertService.errorToast(
            'Oops! it\'s taking a little longer than expected. Please try again soon.');
      } else {
        alertService
            .errorToast('Something went wrong. Please try again in a bit.');
      }
      // alertService.errorToast("Error: ${e.toString()}");
    } finally {
      print('API request completed');
      final cacheDir = await getTemporaryDirectory();
      Future.delayed(const Duration(seconds: 2), () {
        if (cacheDir.existsSync()) {
          cacheDir.deleteSync(recursive: true);
        }
      });
    }
  }

  gotoLogin() {
    Navigator.pushNamedAndRemoveUntil(
      Constants.navigatorKey.currentState!.overlay!.context,
      "login",
      (route) => false,
    );
  }

  postWithTokenAlert(String url, request, [error]) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
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
          //alertService.errorToast(result['message'].toString());
        }
      } else {
        var result = json.decode(response.body);
        alertService.errorToast(result['message'].toString());
      }
    } catch (e) {
      if (e is SocketException) {
        alertService
            .errorToast('No Internet Connection. Please try again later.');
      } else if (e is TimeoutException) {
        alertService.errorToast(
            'Oops! it\'s taking a little longer than expected. Please try again soon.');
      } else {
        alertService
            .errorToast('Something went wrong. Please try again in a bit.');
      }
      // alertService.errorToast("Error: ${e.toString()}");
    } finally {
      print('API request completed');
    }
  }

  getWithTokenAlert(String url, [error]) async {
    SecureStorage secureStorage = SecureStorage();
    final header = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': "Bearer ${secureStorage.getToken().toString()}",
    };
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: header,
      );
      if (response.statusCode == 200) {
        // final decodedResponse = utf8.decode(response.bodyBytes);
        // final data = jsonDecode(decodedResponse);
        // return data;
        return json
            .decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      } else if (response.statusCode == 401) {
        alertService.errorToast("Unauthorized");
        gotoLogin();
        return null;
      } else {
        if (error == null) {
          final decodedResponse = utf8.decode(response.bodyBytes);
          final data = jsonDecode(decodedResponse);
          // var result = json.decode(response.body);
          return data;
          //  alertService.errorToast(
          //    "${response.statusCode}: ${result['message'].toString()}");
        }
      }
    } catch (e) {
      if (error == null) {
        if (e is SocketException) {
          alertService
              .errorToast('No Internet Connection. Please try again later.');
        } else if (e is TimeoutException) {
          alertService.errorToast(
              'Oops! it\'s taking a little longer than expected. Please try again soon.');
        } else {
          alertService
              .errorToast('Something went wrong. Please try again in a bit.');
        }
        // alertService.errorToast("Error: ${e.toString()}");
      }
    } finally {
      print('API request completed');
    }
  }
}
