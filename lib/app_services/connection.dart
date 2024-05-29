import 'dart:convert';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
      alertService.errorToast("Error: ${e.toString()}");
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
      alertService.errorToast("Error: ${e.toString()}");
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
      alertService.errorToast("Error: ${e.toString()}");
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
        alertService.errorToast("Error: ${e.toString()}");
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
      alertService.errorToast("Error: ${e.toString()}");
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
    } catch (e) {
      alertService.errorToast("Error: ${e.toString()}");
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
}
