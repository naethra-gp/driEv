import '../app_config/app_end_points.dart';
import 'connection.dart';

class OtpServices {
  // GENERATE OTP
  generateOtp(String mobile) async {
    Connection connection = Connection();
    var url =
        '${EndPoints.baseApi}/${EndPoints.sendOtp}/$mobile/${EndPoints.otpLength}';
    var response = await connection.getWithoutToken(url);
    return response;
  }

  verifyOtp(request) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.verifyOtp}';
    var response = await connection.postWithoutToken(url, request);
    return response;
  }

  aadhaarSentOtp(request) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi1}/${EndPoints.aadhaarSendOtp}';
    var response =  await connection.postWithToken(url, request);
    return response;
  }
  aadhaarVerifyOtp(request) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi1}/${EndPoints.aadhaarVerifyOtp}';
    var response =  await connection.postWithToken(url, request);
    return response;
  }
}
