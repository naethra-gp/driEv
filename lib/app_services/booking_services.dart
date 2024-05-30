import '../app_config/app_end_points.dart';
import 'connection.dart';

class BookingServices {

  getFare(String bikeNo) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.getBikeDetails}/$bikeNo';
    var response = await connection.getWithToken(url);
    return response;
  }

}