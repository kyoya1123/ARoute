import UIKit
import UserNotifications
import CoreLocation

final class SearchedRouteViewController: UIViewController {
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var descriptionLabels: [UILabel]!
    @IBOutlet var resultLabels: [UILabel]!
    @IBOutlet var notificationSwitch: UISwitch!
    
    var destination: String!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        DispatchQueue.global(qos: .background).async {
            RouteSearcher.scrape(destination: self.destination)
            DispatchQueue.main.async {
                self.setupView()
            }
        }
    }
}

fileprivate extension SearchedRouteViewController {
    
    func setupView() {
        updateLabels()
        setupButton()
        setupSwitch()
    }
    
    func updateLabels() {
        for i in 0..<resultLabels.count {
            resultLabels[i].text = RouteSearcher.searchResult[i]
        }
        let descriptions =
            [NSLocalizedString("destination", comment: ""),
             NSLocalizedString("departure", comment: ""),
             NSLocalizedString("arrival", comment: ""),
             NSLocalizedString("duration", comment: ""),
             NSLocalizedString("platform", comment: ""),
             NSLocalizedString("notification", comment: "")]
        for i in 0..<descriptionLabels.count {
            descriptionLabels[i].text = descriptions[i]
        }
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
        DispatchQueue.global(qos: .background).async {
            RouteSearcher.scrape(destination: self.destination)
            DispatchQueue.main.async {
                self.setupView()
            }
        }
    }
    
    @objc func didSwitched(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            checkNotificationAuthorization()
        case false:
            deleteNotification()
        }
    }
    
    func checkNotificationAuthorization() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            notificationCenter.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized:
                    self.setupNotification()
                case .denied:
                    self.notificationSwitch.setOn(false, animated: true)
                    self.showAlert()
                case .notDetermined:
                    self.requestAuthorization()
                case .provisional:
                    break
                }
            }
        }
    }
    
    func setupNotification() {
        let trigger: UNNotificationTrigger
        let  region = CLCircularRegion(center: DestinationGetter.coordinate, radius: 500, identifier: "destination")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notificationTitle", comment: "")
        content.body = RouteSearcher.searchResult[0]
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: "destination", content: content, trigger: trigger)
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
    
    func deleteNotification() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            for request in requests{
                if request.content.categoryIdentifier == "destination"{
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["destination"])
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
        completionHandler(UNNotificationPresentationOptions.sound)
    }
}
