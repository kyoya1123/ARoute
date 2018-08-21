import UIKit
import ARKit
import SceneKit
import CoreLocation

final class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var locationManager : CLLocationManager!
    var destination: String = "新宿"
    
    override func viewDidLoad() {
        setupLocationManager()
        setupSceneView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let configuration = setupTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.session.pause()
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
    
    func scrape() {
        let doc = Ji(htmlURL: prepareURL())
        let xPaths = ["//*[@id='detail_route_0']/div[1]/div[2]/h3/text()[1]",//出発時刻
            "//*[@id='detail_route_0']/div[3]/div[4]/dl[1]/dd/text()",//到着時刻
            "//*[@id='detail_route_0']/div[1]/div[2]/dl/dd",//所要時間
            "//*[@id='detail_route_0']/div[3]/div[3]/div[2]/ul/li"]//何番線発
        var routeSearchResult = [String]()
        for xPath in xPaths {
            let scrapedText = doc?.xPath(xPath)?.first?.content
            let trimmedText = scrapedText?.trimmingCharacters(in: .whitespacesAndNewlines)
            routeSearchResult.append(trimmedText!)
        }
        print(routeSearchResult)
    }
    
    func prepareURL() -> URL {
        let splitDate = prepareSplitDate()
        let urlString = "https://www.navitime.co.jp/transfer/searchlist?orvStationName=新井薬師前&dnvStationName=高田馬場&thrStationName1=&thrStationCode1=&thrStationName2=&thrStationCode2=&thrStationName3=&thrStationCode3=&month=\(splitDate[0])%2F\(splitDate[1])&day=\(splitDate[2])&hour=\(splitDate[3])&minute=\(splitDate[4])&orvStationCode=&dnvStationCode=&basis=1&from=view.transfer.top&sort=0&wspeed=100&airplane=1&sprexprs=1&utrexprs=1&othexprs=1&mtrplbus=1&intercitybus=1&ferry=1&ctl=020010&atr=2&init="
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
    }
    
    func prepareSplitDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy,MM,dd,hh,mm"
        let dateString = formatter.string(from: Date())
        return dateString.components(separatedBy: ",")
    }
    
    func sphereNode(color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: 0.01)
        geometry.materials.first?.diffuse.contents = color
        return SCNNode(geometry: geometry)
    }
    
    func putSphere(at pos: SCNVector3, color: UIColor, name: String) -> SCNNode {
        let node = sphereNode(color: color)
        sceneView.scene.rootNode.addChildNode(node)
        node.position = pos
        node.name = name
        return node
    }
    
    func textNode(text: String) -> SCNNode {
        let geometry = SCNText(string: text, extrusionDepth: 0.01)
        geometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        if let material = geometry.firstMaterial {
            material.diffuse.contents = UIColor.white
            material.isDoubleSided = true
        }
        let textNode = SCNNode(geometry: geometry)
        
        geometry.font = UIFont.systemFont(ofSize: 0.5)
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
    
    func putText(at pos: SCNVector3, name: String) -> SCNNode {
        let node = textNode(text: name)
        sceneView.scene.rootNode.addChildNode(node)
        node.position = pos
        return node
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        let _ = Route(name: referenceImage.name!)
        DispatchQueue.global().async {
            let color = Route.color
//            var stationsArray = [[String]]()
            let stationCount = Route.stations.count
            for i in 0..<stationCount {
                let sphereNode = self.putSphere(at: SCNVector3((anchor.transform.columns.3.x - 0.04 * 15) + 0.04 * Float(i), anchor.transform.columns.3.y - 0.01, anchor.transform.columns.3.z - 0.01), color: color, name: Route.stations[i])
            let textNode = self.putText(at: SCNVector3((anchor.transform.columns.3.x - 0.04 * 15) + 0.04 * Float(i), anchor.transform.columns.3.y - 0.01, anchor.transform.columns.3.z + 0.01), name: Route.stations[i])
            }
//            let index = stationCount / 3
//            if stationCount % 3 == 0 {
//                stationsArray.append(Array(Route.stations[0..<index]))
//                stationsArray.append(Array(Route.stations[index..<index*2]))
//                stationsArray.append(Array(Route.stations[index*2..<index*3]))
//            }
//            for i in 0..<stationsArray[0].count {
//                let x = anchor.transform.columns.3.x - 0.01 * Float(stationsArray[0].count)
//                let sphereNode = self.putSphere(at: SCNVector3(x + Float(0.025 * Float(i)), anchor.transform.columns.3.y - 0.01 + 0.15, anchor.transform.columns.3.z - 0.01), color: color)
//                let textNode = self.putText(at: SCNVector3(x + Float(0.025 * Float(i)), anchor.transform.columns.3.y - 0.01 + 0.15, anchor.transform.columns.3.z + 0.01), name: stationsArray[0][i])
//            }
//
//            for i in 0..<stationsArray[1].count {
//                let y = (anchor.transform.columns.3.y - 0.01) - 0.008 * Float(stationsArray[1].count)
//                let sphereNode = self.putSphere(at: SCNVector3(anchor.transform.columns.3.x + 0.03 * Float(stationsArray[0].count / 2), y + Float(0.025 * Float(i)), anchor.transform.columns.3.z - 0.01), color: color)
//                let textNode = self.putText(at: SCNVector3(anchor.transform.columns.3.x + 0.03 * Float(stationsArray[0].count / 2), y + Float(0.025 * Float(i)), anchor.transform.columns.3.z + 0.01), name: stationsArray[1][i])
//            }
//
//            for i in 0..<stationsArray[2].count {
//                let x = anchor.transform.columns.3.x - 0.01 * Float(stationsArray[2].count)
//                let sphereNode = self.putSphere(at: SCNVector3(x + Float(0.025 * Float(i)), anchor.transform.columns.3.y - 0.01 - 0.1, anchor.transform.columns.3.z - 0.01), color: color)
//                let textNode = self.putText(at: SCNVector3(x + Float(0.025 * Float(i)), anchor.transform.columns.3.y - 0.01 - 0.1, anchor.transform.columns.3.z + 0.01), name: stationsArray[2][i])
//            }
        }
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if hitResults.count != 0 {
            let result = hitResults[0]
            let material = result.node
            print(material.name)
        }
    }
}
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        StationGetter.getStationName((locations.last?.coordinate)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorization(status)
    }
}
