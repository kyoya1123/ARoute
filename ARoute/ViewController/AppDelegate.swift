import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setLanguage()
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.barTintColor = UIColor(displayP3Red: 46/255, green: 49/255, blue: 54/255, alpha: 1)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.distanceFilter = 100
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.delegate = self
        return true
    }
}

extension AppDelegate {
    func setLanguage() {
        let prefLang = Locale.preferredLanguages.first
        let language = Language(rawValue: String(prefLang!.prefix(2)))
        Language.deviceLang = language
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            showNotification(region: region)
        }
    }
    
    func showNotification(region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notificationTitle", comment: "")
        content.body = RouteSearcher.searchResult["destination"]!
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = region.identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
