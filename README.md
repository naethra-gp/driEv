# driev

A Flutter-based mobile application for EV scooter rentals. Let's driEV is an electric bike rental service operating in Bengaluru and Bhubaneswar. They offer affordable and eco-friendly e-bike rentals for daily commutes and city exploration. The company aims to provide a convenient and sustainable transportation option. While the context does not provide specific information about a Play Store app, it is likely that Let's driEV has a mobile application available on the Play Store for booking and managing e-bike rentals. You can search for "driEV.bike" on the Play Store to find and download their app.

## Links

- Website: [https://driev.bike/](https://driev.bike/)
- Play Store: [Let's driEV](https://play.google.com/store/apps/details?id=com.release.community)

## Version Information

### Flutter & Dart

- Flutter: 3.22.2 (stable channel)
- Dart: 3.4.3
- DevTools: 2.34.3

### Android

- Minimum SDK Version: 21
- Target SDK Version: Latest Flutter SDK version
- Kotlin Version: 1.9.22
- AGP (Android Gradle Plugin): Latest Flutter version
- Google Play Services:
  - Maps: 18.2.0
  - Location: 21.2.0

### iOS

- Minimum iOS Version: As per Flutter requirements
- Current Version: 1.0.23+1 (Live)
- TestFlight Version: 1.0.21

## Project Structure

```
lib/
├── app_pages/
│   └── on_ride/
│       └── widget/
assets/
├── app/
├── img/
├── loading/
└── fonts/
    ├── Roboto.ttf
    ├── Roboto-Regular.ttf
    ├── Poppins-Regular.ttf
    └── Poppins-Bold.ttf
```

## Dependencies

### Core Dependencies

- flutter: Latest SDK version
- cupertino_icons: ^1.0.6
- provider: ^6.1.2
- http: ^1.2.1
- shared_preferences: ^2.3.2

### UI Components

- flutter_easyloading: ^3.0.5
- fluttertoast: ^8.2.5
- flutter_otp_text_field: ^1.1.3+2
- flutter_rating_bar: ^4.0.1
- lottie: ^3.1.2
- animate_do: ^3.3.4

### Storage & State Management

- hive_flutter: ^1.1.0
- hive: ^2.2.3

### Location & Maps

- google_maps_flutter: ^2.7.0
- location: ^5.0.3
- geolocator: ^11.0.0
- geocoding: ^2.0.1
- flutter_polyline_points: ^2.0.0

### Media & Files

- image_picker: ^1.1.2
- image_cropper: ^1.5.1
- flutter_image_compress: ^2.1.0
- file_picker: ^8.0.1
- cached_network_image: ^3.3.1

### Utilities

- permission_handler: ^11.3.1
- connectivity_plus: ^6.0.5
- url_launcher: ^6.2.6
- intl: ^0.19.0
- path_provider: ^2.1.3

### Payment Integration

- paytm_allinonesdk: ^1.2.6

### Development Dependencies

- flutter_test: Latest SDK version
- flutter_lints: ^3.0.2
