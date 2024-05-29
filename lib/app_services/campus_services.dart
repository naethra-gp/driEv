import '../app_config/app_end_points.dart';
import 'connection.dart';

class CampusServices {
  getAllCampus( ) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.getAllCampus}';
    var response = await connection.getWithToken(url);
    return response;
  }
  getCampusById(String id) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.campusById}/$id';
    var response = await connection.getWithToken(url);
    return response;
  }
  getAllColleges( ) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.getAllColleges}';
    var response = await connection.getWithToken(url);
    return response;
  }
  voteCollege(dynamic params, [error]) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.voteCollege}';
    var response = await connection.postWithToken(url, params, error);
    return response;
  }
  uploadImage(String mobileNo, filePath) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.uploadFile}/$mobileNo';
    var response = await connection.uploadFile(url, filePath);
    return response;
  }
}
