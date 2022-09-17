import UIKit
import Flutter
import GoogleMobileAds
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ kGADSimulatorID ]
    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["7e30cb413fde66b850b42bee8253f17a" ]
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
