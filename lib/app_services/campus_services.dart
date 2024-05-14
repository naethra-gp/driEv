import '../app_config/app_end_points.dart';
import 'connection.dart';

class CampusServices {
  // generateToken( request) async {
  //   Connection connection = Connection();
  //   var url = '${EndPoints.baseApi1}/${EndPoints.generatedToken}';
  //   var response = await connection.postWithoutToken(url, request);
  //   return response;
  // }
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
  voteColleges(String collegeId) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.voteCollege}/$collegeId';
    var response = await connection.getWithToken(url);
    return response;
  }
  uploadImage(String mobileNo, filePath) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.uploadFile}/$mobileNo';
    var response = await connection.uploadFile(url, filePath);
    return response;
  }
}
