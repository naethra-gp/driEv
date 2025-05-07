import UIKit
import Flutter
import GoogleMaps
import Firebase // Add this

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure() // Initialize Firebase
    GMSServices.provideAPIKey("AIzaSyA1BR25d81VWTluf66WscvlTb_T1kRLQeA")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
