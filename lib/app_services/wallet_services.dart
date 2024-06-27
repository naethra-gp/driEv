import '../app_config/app_end_points.dart';
import 'connection.dart';

class WalletServices{
  getWalletTransaction(String mobileNo) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi}/${EndPoints.transactionByContact}/$mobileNo';
    var response = await connection.getWithToken(url);
    return response;
  }
  withdrawMoneyFromWallet(dynamic params, [error]) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi1}/${EndPoints.withdrawMoney}';
    var response = await connection.postWithToken(url, params, error);
    return response;
  }

  initiateTransaction(dynamic params, [error]) async {
    Connection connection = Connection();
    var url = '${EndPoints.payment}/${EndPoints.initiateTransaction}';
    var response = await connection.postWithToken(url, params, error);
    return response;
  }
  getWalletBalance(String mobileNo) async {
    Connection connection = Connection();
    var url = '${EndPoints.baseApi1}/${EndPoints.walletBalance}/$mobileNo';
    var response = await connection.getWithToken(url);
    return response;
  }
}