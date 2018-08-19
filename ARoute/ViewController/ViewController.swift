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
        scrape()
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
        let route = Route(name: referenceImage.name!)!
        DispatchQueue.global().async {
            let color = route.color()
            for i in 0..<route.stations().count {
                self.putSphere(at: SCNVector3((anchor.transform.columns.3.x - 0.05 * 15) + 0.05 * Float(i), anchor.transform.columns.3.y - 0.01, anchor.transform.columns.3.z - 0.01), color: color)
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
