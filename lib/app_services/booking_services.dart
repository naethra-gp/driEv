import '../app_config/app_end_points.dart';
import 'connection.dart';

class BookingServices {
  getFare(String bikeNo) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.getBikeDetails}/$bikeNo';
    var response = await connection.getWithToken(url);
    return response;
  }

  getWalletBalance(String mobileNo) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi1}/${EndPoints.walletBalance}/$mobileNo';
    var response = await connection.getWithToken(url);
    return response;
  }

  startMyRide(dynamic params, [error]) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.createMyRide}';
    var response = await connection.postWithToken(url, params, error);
    return response;
  }

  getRideDetails(String rideId) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.rideDetails}/$rideId';
    var response = await connection.getWithToken(url);
    return response;
  }

  getRideEndPin(String rideId) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.getRideEndPin}/$rideId';
    var response = await connection.getWithToken(url);
    return response;
  }
  rideEndConfirmation(String mobile) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.rideEndConfirmation}/$mobile';
    var response = await connection.getWithToken(url);
    return response;
  }
}
