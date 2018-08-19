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
//        scrape()
        setupSceneView()
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
        let xPaths = ["//*[@id='route01']/div[4]/div[1]/ul[1]/li",//出発時刻
                      "//*[@id='route01']/div[4]/div[3]/ul[1]/li",//到着時刻
                      "//*[@id='route01']/dl/dd[1]/ul/li[1]/text()",//所要時間
                      "//*[@id='route01']/div[4]/div[2]/div/ul/li[2]/span[1]"]//何番線発
        var routeSearchResult = [String]()
        for xPath in xPaths {
            let scrapedText = doc?.xPath(xPath)?.first?.content
            routeSearchResult.append(scrapedText!)
        }
    }
    
    func prepareURL() -> URL {
        let splitDate = prepareSplitDate()
        let urlString = "https://transit.yahoo.co.jp/search/result?from=\(StationGetter.nearestStation)&to=高田馬場&y=\(splitDate[0])&m=\(splitDate[1])&d=\(splitDate[2])&hh=\(splitDate[3])&m2=\(splitDate[4].suffix(1))&m1=\(splitDate[4].prefix(1))"
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
    }
    
    func prepareSplitDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy,MM,dd,hh,mm"
        let dateString = formatter.string(from: Date())
        return dateString.components(separatedBy: ",")
    }
    
    func sphereNode(color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: 0.02)
        geometry.materials.first?.diffuse.contents = color
        return SCNNode(geometry: geometry)
    }
    
    func putSphere(at pos: SCNVector3, color: UIColor) -> SCNNode {
        let node = sphereNode(color: color)
        sceneView.scene.rootNode.addChildNode(node)
        node.position = pos
        return node
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        let imageName = referenceImage.name
        DispatchQueue.global().async {
            let color = Route.init(name: imageName!)?.color()
            for i in 0..<30 {
                self.putSphere(at: SCNVector3((anchor.transform.columns.3.x - 0.05 * 15) + 0.05 * Float(i), anchor.transform.columns.3.y - 0.01, anchor.transform.columns.3.z - 0.01), color: color!)
            }
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