import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_pages/index.dart';
import '../app_pages/test/test.dart';
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
        case "select_vehicle":
          Map args = settings.arguments as Map;
          return SelectVehiclePage(stationDetails: args['params']);
        case "registration":
          String id = settings.arguments as String;
          return RegistrationPage(campusId: id);
        case "profile":
          return const ProfilePage();
        case "test":
          return const LoginTest();
      }
      return const LandingPage();
    });
  }
}
