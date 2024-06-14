import '../app_config/app_end_points.dart';
import 'connection.dart';

class FeedbackServices{

  rideFeedBack(dynamic params, [error]) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.rideFeedback}';
    var response = await connection.postWithToken(url, params, error);
    return response;
  }
  getRideHistory(String mobileNo) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi1}/${EndPoints.rideHistory}/$mobileNo';
    var response = await connection.getWithToken(url);
    return response;
  }
}
