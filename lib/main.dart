import 'package:driev/app_config/app_constants.dart';
import 'package:driev/app_themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'app_config/app_routes.dart';
import 'app_utils/app_provider/connectivity_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
  );
  await Hive.initFlutter();
  await Hive.openBox(Constants.storageBox);
  runApp(const MyApp());
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
