import UIKit
import ARKit
import SceneKit
import CoreLocation

final class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var locationManager : CLLocationManager!
    var destination: String = "新宿"
    
    override func viewDidLoad() {
        setupLocationManager()
        setupSceneView()
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
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        checkAuthorization(status)
    }
    
    func checkAuthorization(_ status: CLAuthorizationStatus) {
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
    
    func putStation(at position: SCNVector3, name: String) {
        var color = Route.color
        if name == StationGetter.nearestStation {
            color = .red
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
            RouteSearcher.scrape(destination: resultNode.name!)
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
            let baseX = anchor.transform.columns.3.x - 0.04 * Float(stationCount)
            let baseY = anchor.transform.columns.3.y - 0.01
            let baseZ = anchor.transform.columns.3.z - 0.01
            for i in 0..<stationCount {
                self.putStation(at: SCNVector3(baseX + 0.04 * Float(i), baseY, baseZ), name: Route.stations[i])
            }
        }
    }
}
/*
 横一列
 for i in 0..<stationCount {
 self.putStation(at: SCNVector3((baseX - 0.04 * stationCount) + 0.04 * Float(i), baseY, baseZ), name: Route.stations[i])
 }
 
 
*/

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.global().async {
            StationGetter.getStationName((locations.last?.coordinate)!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorization(status)
    }
}
