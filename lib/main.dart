import 'package:driev/app_config/app_constants.dart';
import 'package:driev/app_themes/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'app_config/app_routes.dart';
import 'app_utils/app_provider/connectivity_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(Constants.storageBox);

  /// FIREBASE SETUP
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Enable Performance Monitoring
  FirebasePerformance performance = FirebasePerformance.instance;
  performance.setPerformanceCollectionEnabled(true);
  // performance.setPerformanceCollectionEnabled(!kDebugMode);

  await FlutterStatusbarcolor.setStatusBarColor(Colors.white);
  if (!useWhiteForeground(Colors.white)) {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  } else {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConnectivityProvider(),
      child: MaterialApp(
        title: 'driEV',
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
