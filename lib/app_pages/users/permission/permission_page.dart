import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  String smsPermission =
      'We need SMS permission to automatically detect OTPs sent to your phone. This will make your login/signup process faster and easier.';
  String locationPermission =
      'We must obtain permission to user’s current location and their desired destination. By determining the distance between these two points.';
  String cameraPermission =
      'We must obtain permission to access the customer\'s Camera to take a picture and upload to live server.';
  String storagePermission =
      'We must obtain permission to access the select picture or file and upload to live server.';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              const Text(
                "We required following permissions",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(height: 20.0),
              // permissionWidget(
              //   Icons.sms_outlined,
              //   'SMS Permission',
              //   smsPermission,
              // ),
              const Divider(),
              permissionWidget(
                Icons.location_searching,
                'Location Permission',
                locationPermission,
              ),
              const Divider(),
              permissionWidget(
                Icons.camera_alt_outlined,
                'Camera Permission',
                locationPermission,
              ),
              const Divider(),
              permissionWidget(
                Icons.sd_storage_outlined,
                'Storage Permission',
                storagePermission,
              ),
              const Divider(),
              const SizedBox(height: 25),
              AppButtonWidget(
                title: 'Proceed',
                onPressed: () {
                  getPermission(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  getPermission(BuildContext ctx) async {
    SecureStorage secureStorage = SecureStorage();
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.location,
      Permission.locationAlways,
      // Permission.sms,
      Permission.photos,
      Permission.mediaLibrary,
      Permission.notification,
    ].request();
    secureStorage.save("permission", true);
    debugPrint("statuses -- $statuses");
    Navigator.pushNamedAndRemoveUntil(ctx, "landing_page", (router) => false);
  }

  Widget permissionWidget(icon, title, description) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        radius: 25,
        child: Icon(
          icon,
          color: AppColors.white,
          size: 28,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(description, textAlign: TextAlign.justify),
    );
  }
}
