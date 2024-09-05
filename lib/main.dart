import 'package:device_preview/device_preview.dart';
import 'package:driev/app_config/app_constants.dart';
import 'package:driev/app_themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'app_config/app_routes.dart';
import 'app_utils/app_provider/connectivity_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(Constants.storageBox);

  await FlutterStatusbarcolor.setStatusBarColor(Colors.white);
  if (!useWhiteForeground(Colors.white)) {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  } else {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  }

  // await FlutterStatusbarcolor.setNavigationBarColor(Colors.white);
  // if (!useWhiteForeground(Colors.white)) {
  //   FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
  // } else {
  //   FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
  // }

  runApp(const MyApp());
  // runApp(DevicePreview(
  //   enabled: true,
  //   builder: (context) => const MyApp(),
  // ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConnectivityProvider(),
      child: MaterialApp(
        title: 'Drive EV',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        initialRoute: 'splash',
        builder: EasyLoading.init(),
        onGenerateRoute: AppRoute.allRoutes,
        navigatorKey: Constants.navigatorKey,
        theme: AppThemes.lightTheme,
      ),
    );
  }
}
