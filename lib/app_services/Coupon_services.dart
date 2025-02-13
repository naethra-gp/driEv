import '../app_config/app_end_points.dart';
import 'connection.dart';

class CouponServices {

  getCouponCode(String mobileNo) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi1}/${EndPoints.assignCouponCode}/$mobileNo';
    var response = await connection.getWithToken(url, false);
    return response;
  }
  validateCouponCode(String code) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.validateCode}/$code';
    var response = await connection.getWithToken(url);
    return response;
  }
}