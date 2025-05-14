import 'package:driev/app_pages/referral_screen/referral_screen.dart';
import 'package:driev/app_pages/ride_history/ride_history.dart';
import 'package:driev/app_pages/wallet_screens/wallet_summary.dart';
import 'package:driev/app_pages/wallet_screens/walllet_all_transaction.dart';
import 'package:driev/app_pages/wallet_screens/withdraw_amount.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_pages/index.dart';
import '../app_pages/referral_screen/referCode_apply.dart';
import '../app_pages/ride_summary/summary_ride.dart';
import '../app_pages/scan_to_endride/end_ride_scan.dart';
import '../app_utils/app_provider/connectivity_provider.dart';

class AppRoute {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) {
      final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
      if (!isOnline) {
        return const NoInterNet();
      }
      switch (settings.name) {
        case "splash":
          return const SplashScreen();
        case "landing_page":
          return const LandingPage();
        case "login":
          dynamic mobile = settings.arguments;
          return LoginPage(mobileNumber: mobile);
        case "home":
          return const HomePage();
        case "verify_otp":
          String mobile = settings.arguments as String;
          return VerifyOTP(mobileNumber: mobile);
        case "success_page":
          return const SuccessScreen();
        case "extend_bike":
          List args = settings.arguments as List;
          return ExtendBikeTimer(blockRide: args);
        case "otp_error_page":
          return const OtpErrorPage();
        case "choose_your_campus":
          return const ChooseYourCampus();
        case "vote_your_campus":
          return const VoteForYourCampus();
        case "vote_campus_success":
          return const VoteSuccessPage();
        case "vote_campus_error":
          Map args = settings.arguments as Map;
          return VoteErrorScreen(params: args['params']);
        case "rank_list":
          return const RankList();
        case "registration":
          String id = settings.arguments as String;
          return RegistrationPage(campusId: id);
        case "profile":
          return const ProfilePage();
        // Vehicle Routes
        case "select_vehicle":
          List args = settings.arguments as List;
          return VehicleCloserMatches(params: args);
        // return SelectVehiclePage(stationDetails: args['params']);
        case "error_bike":
          return const ErrorBikes();
        case "bike_fare_details":
          Map args = settings.arguments as Map;
          return CheckBikeFareDetails(data: args['query']);
        // return BikeFareDetails(stationDetails: args['query']);
        case "booking_success":
          String id = settings.arguments as String;
          return BookingSuccessful(rideId: id);
        case "booking_failed":
          return const BookingFailed();
        case "scan_to_unlock":
          List args = settings.arguments as List;
          return ScanToUnlock(data: args);
        case "time_out":
          List args = settings.arguments as List;
          return TimeOutError(data: args);
        case "end_time_out":
          List args = settings.arguments as List;
          return EndTimeOut(data: args);
        case "on_ride":
          String id = settings.arguments as String;
          return OnRidePage(rideId: id);
        // return OnRide(rideId: id);
        case "ride_summary":
          String id = settings.arguments as String;
          return RideSummary(rideId: id);
        case "scan_to_end_ride":
          List args = settings.arguments as List;
          return EndRideScanner(rideID: args);
        case "rate_this_raid":
          String id = settings.arguments as String;
          return RateThisRide(rideId: id);
        case "refer_screen":
          return const ReferralScreen();
        case "ride_history":
          return const RideHistory();
        case "wallet_summary":
          return const WalletSummary();
        case "withdraw_amount":
          return const WithdrawAmount();
        case "all_transaction":
          List id = settings.arguments as List;
          return AllTransaction(allTransaction: id);
        case "referral_in_signup":
          return const ReferCodeApply();
        case "add_more_fund":
          final args = settings.arguments as Map<String, Object>;
          final stationDetails = args['stationDetails'] as List;
          final rideId = args['rideId'] as String;
          final rideID = args['rideID'] as List;
          return AddMoreFund(
            stationDetails: stationDetails,
            rideId: rideId,
            rideID: rideID,
          );
        case "transaction_success":
          return const TransactionSuccess();
        case "transaction_failure":
          return const TransactionFailure();
        case "ride_details":
          List args = settings.arguments as List;
          return RideDetails(rideId: args);
      }
      return const LandingPage();
    });
  }
}
