import UIKit
import UserNotifications
import CoreLocation

final class SearchedRouteViewController: UIViewController {
    
    var closeButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    @IBOutlet var descriptionLabels: [UILabel]!
    @IBOutlet var resultLabels: [UILabel]!
    @IBOutlet var notificationSwitch: UISwitch!
    
    var destination: String!
    let locationManager = CLLocationManager()
    var region = CLCircularRegion()
    var currentLine: Line!
    
    override func viewDidLoad() {
        setupView()
        setupLocationManager()
        DispatchQueue.global(qos: .background).async {
            self.searchRoute()
            DispatchQueue.main.async {
                self.updateLabels()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
    }
}

private extension SearchedRouteViewController {
    
    func setupView() {
        setupDescriptions()
        setupSwitch()
    }
    
    func setupNavigationBar() {
        setupButton()
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = true
        navigationItem.setLeftBarButton(closeButton, animated: false)
        navigationItem.setRightBarButton(reloadButton, animated: false)
    }
    
    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func updateLabels() {
        if Language.deviceLang == .japanese {
            resultLabels[0].text = destination
        } else {
            resultLabels[0].text = currentLine.stationNames[1][currentLine.stationNames[0].index(of: destination)!]
        }
        resultLabels[1].text = RouteSearcher.searchResult["departure"]
        resultLabels[2].text = RouteSearcher.searchResult["arrival"]
        resultLabels[3].text = RouteSearcher.searchResult["duration"]
        resultLabels[4].text = RouteSearcher.searchResult["platform"]
    }
    
    func setupDescriptions() {
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
        let tmpClose = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        tmpClose.setImage(UIImage(named: "back"), for: .normal)
        tmpClose.addTarget(self, action: #selector(didtapClose), for: .touchUpInside)
        closeButton = UIBarButtonItem(customView: tmpClose)
        closeButton.customView?.widthAnchor.constraint(equalToConstant: 35).isActive = true
        closeButton.customView?.heightAnchor.constraint(equalToConstant: 35).isActive = true
        let tmpReload = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        tmpReload.setImage(UIImage(named: "reset"), for: .normal)
        tmpReload.addTarget(self, action: #selector(didtapReload), for: .touchUpInside)
        reloadButton = UIBarButtonItem(customView: tmpReload)
        reloadButton.customView?.widthAnchor.constraint(equalToConstant: 35).isActive = true
        reloadButton.customView?.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    func setupSwitch() {
        notificationSwitch.addTarget(self, action: #selector(didSwitched(_:)), for: .valueChanged)
    }
    
    @objc func didtapClose() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didtapReload() {
        DispatchQueue.global(qos: .background).async {
            self.searchRoute()
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
            if CLLocationManager.isMonitoringAvailable(for: CLRegion.self) {
                locationManager.stopMonitoring(for: region)
            }
        }
    }
    
    func checkNotificationAuthorization() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            notificationCenter.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized:
                    self.checkLocationAuthorization()
                    self.setupRegion()
                case .denied:
                    self.notificationSwitch.setOn(false, animated: true)
                    self.showNotificationAlert()
                case .notDetermined:
                    self.requestAuthorization()
                case .provisional:
                    break
                }
            }
        }
    }
    
    func searchRoute() {
        let stationNames = currentLine.stationNames[0]
        let departureIndex = stationNames.index(of: StationGetter.stationName)!
        let destinationIndex = stationNames.index(of: destination)!
        RouteSearcher.search(departure: currentLine.stationCode[departureIndex], destination: currentLine.stationCode[destinationIndex])
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            return
        default:
            showLocationAlert()
        }
    }
    
    func setupRegion() {
        print(locationManager.desiredAccuracy)
        region = CLCircularRegion(center: DestinationGetter.coordinate, radius: 500, identifier: "destination")
        region.notifyOnExit = false
        locationManager.startMonitoring(for: region)
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
    
    func showLocationAlert() {
        notificationSwitch.setOn(false, animated: true)
        let alert = UIAlertController(title: NSLocalizedString("locationUsageTitle", comment: ""), message: NSLocalizedString("locationUsageMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showNotificationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("notificationAlertTitle", comment: ""), message: NSLocalizedString("alertMessage", comment: ""), preferredStyle: .alert)
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
