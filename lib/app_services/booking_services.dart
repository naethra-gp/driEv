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

  blockBike(dynamic params, [error]) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.blockBike}';
    var response = await connection.postWithTokenAlert(url, params, error);
    return response;
  }

  releaseBlockedBike(String blockId) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.releaseBlockedBike}/$blockId';
    var response = await connection.getWithToken(url);
    return response;
  }

  extendBlocking(dynamic params, [error]) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.extendBlocking}';
    var response = await connection.postWithToken(url, params, error);
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
    var response = await connection.getWithTokenAlert(url);
    return response;
  }

  rideEndConfirmation(String mobile) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.rideEndConfirmation}/$mobile';
    var response = await connection.getWithToken(url);
    return response;
  }
}
