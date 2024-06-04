import 'package:flutter/material.dart';

import '../../app_storages/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    debugPrint('--->>> Splash Screen <<<---');
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      getRoute();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset("assets/img/logo.png"),
        ),
      ),
    );
  }

  getRoute() async {
    bool isLogin = await secureStorage.get("isLogin") ?? false;
    if (isLogin) {
      // if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
    } else {
      // if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, "landing_page", (route) => false);
    }
  }
}
