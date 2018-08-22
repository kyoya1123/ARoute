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
    
    func sphereNode(color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: 0.01)
        geometry.materials.first?.diffuse.contents = color
        return SCNNode(geometry: geometry)
    }
    
    func putSphere(at pos: SCNVector3, color: UIColor, name: String) {
        let node = sphereNode(color: color)
        node.position = pos
        node.name = name
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func textNode(text: String) -> SCNNode {
        let geometry = SCNText(string: text, extrusionDepth: 0.01)
        geometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        if let material = geometry.firstMaterial {
            material.diffuse.contents = UIColor.white
            material.isDoubleSided = true
        }
        let textNode = SCNNode(geometry: geometry)
        
        geometry.font = UIFont(name: "HiraginoSans-W6", size: 1);
//            UIFont.systemFont(ofSize: 0.5)
        textNode.scale = SCNVector3Make(0.02, 0.02, 0.02)
        
        // Translate so that the text node can be seen
        let (min, max) = geometry.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x)/2, min.y - 0.5, 0)
        
        // Always look at the camera
        let node = SCNNode()
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        node.constraints = [billboardConstraint]
        node.addChildNode(textNode)
        return node
    }
    
    func putText(at pos: SCNVector3, name: String) {
        let node = textNode(text: name)
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
        let referenceImage = imageAnchor.referenceImage
        let _ = Route(name: referenceImage.name!)
        DispatchQueue.global().async {
            let color = Route.color
            let stationCount = Route.stations.count
            for i in 0..<stationCount {
                self.putSphere(at: SCNVector3((anchor.transform.columns.3.x - 0.04 * 15) + 0.04 * Float(i), anchor.transform.columns.3.y - 0.01, anchor.transform.columns.3.z - 0.01), color: color, name: Route.stations[i])
                self.putText(at: SCNVector3((anchor.transform.columns.3.x - 0.04 * 15) + 0.04 * Float(i), anchor.transform.columns.3.y - 0.01, anchor.transform.columns.3.z + 0.01), name: Route.stations[i])
            }
        }
    }
}

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
