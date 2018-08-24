import UIKit
import ARKit
import SceneKit
import CoreLocation
import UserNotifications

final class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var helpButton: UIButton!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        setupLocationManager()
        setupSceneView()
        setupButtons()
        setupNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sceneView.session.run(setupTrackingConfiguration())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let position = touch.location(in: sceneView)
        tappedScreen(position)
    }
}

fileprivate extension ViewController {
    
    func setupNotification() {
        checkNotificationAuthorization()
        let trigger: UNNotificationTrigger
        let  region = CLCircularRegion(center: DestinationGetter.coordinate, radius: 500, identifier: "destination")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "東中野"
        content.body = "目的地に到着"
        content.sound = UNNotificationSound.default
        
        
        let request = UNNotificationRequest(identifier: "uuid", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func setupButtons() {
        resetButton.addTarget(self, action: #selector(didtapReset), for: .touchUpInside)
        helpButton.addTarget(self, action: #selector(didtapHelp), for: .touchUpInside)
    }
    
    @objc func didtapReset() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        sceneView.scene.rootNode.enumerateChildNodes { node, arg   in
            node.removeFromParentNode()
        }
    }
    
    @objc func didtapHelp() {
        
    }
    
    func setupSceneView() {
        sceneView.delegate = self
        #if DEBUG
        sceneView.showsStatistics = true
        #endif
    }
    
    func setupTrackingConfiguration() -> ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        configuration.detectionImages = referenceImages
        return configuration
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        checkLocationAuthorization(status)
    }
    
    func checkNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) {(granted, error) in
            if !granted {
                print("通知オンにしねえとダメよ")
            }
        }
    }
    
    func checkLocationAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            showAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "位置情報の使用が許可されていません", message: "設定を変更する", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func complementaryColor(baseColor: UIColor) -> UIColor {
        let ciColor = CIColor(color: baseColor)
        let compRed = 1 - ciColor.red
        let compGreen = 1 - ciColor.green
        let compBlue = 1 - ciColor.blue
        return UIColor(red: compRed, green: compGreen, blue: compBlue, alpha: 1)
    }
    
    func putStation(at position: SCNVector3, name: String) {
        var color = Route.color
        if name == StationGetter.stationName {
            color = complementaryColor(baseColor: Route.color)
        }
        putSphere(at: position, color: color, name: name)
        let textPosition = SCNVector3(position.x, position.y + 0.01, position.z)
        putText(at: textPosition, name: name)
    }
    
    func putSphere(at pos: SCNVector3, color: UIColor, name: String) {
        let node = SCNNode.sphereNode(color: color)
        node.position = pos
        node.name = name
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func putText(at pos: SCNVector3, name: String) {
        let node = SCNNode.textNode(text: name)
        node.position = pos
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func tappedScreen(_ position: CGPoint) {
        let hitResults = sceneView.hitTest(position, options: [:])
        if hitResults.count != 0 {
            let resultNode = hitResults[0].node
            print(resultNode.name!)
            if resultNode.name != StationGetter.stationName {
                let result = RouteSearcher.scrape(destination: resultNode.name!)
                DestinationGetter.getLocation(destination: resultNode.name!)
                let alert = UIAlertController(title: "結果結果", message: "\(result[0]),\(result[1]),\(result[2])", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        guard let imageName = imageAnchor.referenceImage.name else { return }
        Route.info(name: imageName)
        DispatchQueue.global().async {
            let stationCount = Route.stations.count
            let baseX = anchor.transform.columns.3.x - 0.04 * Float(stationCount / 2)
            let baseY = anchor.transform.columns.3.y - 0.01
            let baseZ = anchor.transform.columns.3.z - 0.01
            for i in 0..<stationCount {
                self.putStation(at: SCNVector3(baseX + 0.04 * Float(i), baseY, baseZ), name: Route.stations[i])
            }
            //            let spaceSize = 0.04
            //            var stationArray = [[String]]()
            //            switch stationCount % 3 {
            //            case 0:
            //                let index = stationCount / 3
            //                stationArray.append(Array(Route.stations[0..<index]))
            //                stationArray.append(Array(Route.stations[index..<index*2]))
            //                stationArray.append(Array(Route.stations[index*2..<stationCount - 1]))
            //            case 1:
            //                print("")
            //            case 2:
            //                print("")
            //            default: break
            //            }
            //
            //            for i in 0..<stationArray[0].count {
            //
            //            }
        }
    }
}
/*
 横一列
 for i in 0..<stationCount {
 - 0.04 * Float(stationCount)
 self.putStation(at: SCNVector3(baseX + 0.04 * Float(i), baseY, baseZ), name: Route.stations[i])
 }
 */

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.global().async {
            StationGetter.getStationName((locations.last?.coordinate)!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization(status)
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
