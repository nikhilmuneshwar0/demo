import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Initialize Google Maps SDK with your API key
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    
    // Register plugins with the Flutter framework
    GeneratedPluginRegistrant.register(with: self)
    
    // Set minimum background fetch interval (optional)
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    
    // Configure other services if needed
    configureAppearance()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Optional: Configure global app appearance
  private func configureAppearance() {
    if #available(iOS 15.0, *) {
      let navigationBarAppearance = UINavigationBarAppearance()
      navigationBarAppearance.configureWithOpaqueBackground()
      navigationBarAppearance.titleTextAttributes = [
        .foregroundColor: UIColor.white
      ]
      navigationBarAppearance.backgroundColor = UIColor(red: 0.13, green: 0.14, blue: 0.15, alpha: 1.00)
      UINavigationBar.appearance().standardAppearance = navigationBarAppearance
      UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
  }
  
  // Handle incoming URLs (optional)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Handle deep links if needed
    return super.application(app, open: url, options: options)
  }
  
  // Handle notifications (optional)
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Handle push notification registration
  }
}