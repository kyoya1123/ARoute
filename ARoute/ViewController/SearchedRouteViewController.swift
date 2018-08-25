import UIKit
import UserNotifications
import CoreLocation

final class SearchedRouteViewController: UIViewController {
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var destinationLabel: UILabel!
    @IBOutlet var leavingTimeLabel: UILabel!
    @IBOutlet var arrivingTimeLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var platformLabel: UILabel!
    @IBOutlet var notificationSwitch: UISwitch!
    
    var destination: String!
    
    override func viewDidLoad() {
        RouteSearcher.scrape(destination: destination)
        setupView()
    }
}

fileprivate extension SearchedRouteViewController {
    
    func setupView() {
        updateLabels()
        setupButton()
        setupSwitch()
    }
    
    func updateLabels() {
        destinationLabel.text = destination
        leavingTimeLabel.text = RouteSearcher.searchResult[0]
        arrivingTimeLabel.text = RouteSearcher.searchResult[1]
        //TODO: 時間の時
        durationLabel.text = RouteSearcher.searchResult[2] + "min"
        platformLabel.text = RouteSearcher.searchResult[3]
    }
    
    func setupButton() {
        closeButton.addTarget(self, action: #selector(didtapClose), for: .touchUpInside)
        reloadButton.addTarget(self, action: #selector(didtapReload), for: .touchUpInside)
    }
    
    func setupSwitch() {
        notificationSwitch.addTarget(self, action: #selector(didSwitched(_:)), for: .valueChanged)
    }
    
    @objc func didtapClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didtapReload() {
        RouteSearcher.scrape(destination: destination)
        updateLabels()
    }
    
    @objc func didSwitched(_ sender: UISwitch) {
        if sender.isOn {
            if checkAuthorization() {
                setupNotification()
            }
        }
    }
    
    func checkAuthorization() -> Bool {
        var result = false
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                result = true
            case .denied:
                self.notificationSwitch.setOn(false, animated: true)
                self.showAlert()
            case .notDetermined:
                self.requestAuthorization()
            default: break
            }
        }
        return result
    }
    
    func setupNotification() {
        let trigger: UNNotificationTrigger
        let  region = CLCircularRegion(center: DestinationGetter.coordinate, radius: 500, identifier: "destination")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = destination
        content.body = "まもなく到着します"
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: "arriving", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if !granted {
                DispatchQueue.main.async {
                    self.notificationSwitch.setOn(false, animated: true)
                }
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "通知が許可されていません", message: "設定を変更する", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let url = URL(string: "\(UIApplication.openSettingsURLString)&path=NOTIFICATION") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension SearchedRouteViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
