import 'dart:async';

import 'package:driev/app_config/app_config.dart';
import 'package:driev/app_themes/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'app_utils/app_provider/connectivity_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    await Hive.openBox(Constants.storageBox);

    /// FIREBASE SETUP
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    /// Enable Crashlytics
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    /// Enable Performance Monitoring
    FirebasePerformance performance = FirebasePerformance.instance;
    performance.setPerformanceCollectionEnabled(kReleaseMode);

    /// MAIN RUN APP
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) {
      runApp(const MyApp());
    });
  }, (error, stack) {
    FlutterError.onError = (FlutterErrorDetails details) {
      printResponse("===> MAIN FILE ERROR: ${details.exceptionAsString()}");
      try {
        FirebaseCrashlytics.instance.recordFlutterError(details);
      } on Exception catch (e) {
        printResponse("===> MAIN FILE EXCEPTION ERROR: ${e.toString()}");
      }
    };
  });
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
