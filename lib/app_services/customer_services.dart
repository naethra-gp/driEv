import 'dart:developer';

import '../app_config/app_end_points.dart';
import 'connection.dart';

class CustomerService {
  createCustomer(request) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.createCustomer}';
    var response = await connection.postWithToken(url, request);
    return response;
  }

  getCustomer(mobile, [noError]) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.getCustomer}/$mobile';
    var response = await connection.getWithToken(url, noError);
    return response;
  }

  uploadImage(filePath, user) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi1}/${EndPoints.uploadDocument}';
    var response = await connection.reUploadDocument(url, filePath, user);
    return response;
  }

  sentEmail(request) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi1}/${EndPoints.sentEmail}';
    var response = await connection.postWithToken(url, request);
    return response;
  }

  verifyEmail(String email) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.verifyEmail}/$email';
    var response = await connection.getWithToken(url);
    return response;
  }
}
