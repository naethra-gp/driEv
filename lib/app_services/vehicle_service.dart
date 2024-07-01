import '../app_config/app_end_points.dart';
import 'connection.dart';

class VehicleService {
  getVehiclesByPlan(String sId, String plan) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.getVehiclesByPlan}/$sId/$plan';
    var response = await connection.getWithToken(url);
    return response;
  }

  getPlansByStation(String sId) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.getPlansByStation}/$sId';
    var response = await connection.getWithToken(url);
    return response;
  }

  getActiveRides(String mobileNo) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.activeRides}/$mobileNo';
    var response = await connection.getWithToken(url);
    return response;
  }
  getBlockedRides(String mobileNo) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.blockedRides}/$mobileNo';
    var response = await connection.getWithToken(url);
    return response;
  }
}
