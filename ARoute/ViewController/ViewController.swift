import UIKit
import ARKit
import SceneKit
import CoreLocation

final class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var helpButton: UIButton!
    @IBOutlet var frameImageView: UIImageView!
    @IBOutlet var languageSegment: UISegmentedControl!
    
    var locationManager: CLLocationManager!
    var currentLine: Line!
    var deviceLang: Language!
    
    override func viewDidLoad() {
        setupLocationManager()
        setLanguage()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetTracking()
        sceneView.session.run(setupTrackingConfiguration())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: sceneView)
        tappedScreen(position)
    }
    
    override func viewDidLayoutSubviews() {
        let userDefault = UserDefaults.standard
        let launched = userDefault.bool(forKey: "launched")
        if !launched {
            showTutorial()
            userDefault.set(true, forKey: "launched")
        }
    }
}

fileprivate extension ViewController {
    
    func setLanguage() {
        let prefLang = Locale.preferredLanguages.first
        if let language = Language(rawValue: String(prefLang!.prefix(2))) {
            deviceLang = language
        } else {
            deviceLang = .english
        }
    }
    
    func setupView() {
        setupButtons()
        setupSegmentControl()
        setupSceneView()
    }
    
    func setupButtons() {
        resetButton.addTarget(self, action: #selector(didtapReset), for: .touchUpInside)
        helpButton.addTarget(self, action: #selector(didtapHelp), for: .touchUpInside)
    }
    
    func setupSegmentControl() {
        if deviceLang == .japanese {
            languageSegment.removeFromSuperview()
            return
        }
        let titles = deviceLang.segmentTitle
        languageSegment.setTitle(titles[0], forSegmentAt: 0)
        languageSegment.setTitle(titles[1], forSegmentAt: 1)
        languageSegment.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Kano-regular", size: 15) ?? UIFont()], for: .normal)
    }
    
    @objc func didtapReset() {
        resetTracking()
    }
    
    @objc func didtapHelp() {
        showTutorial()
    }
    
    func setupSceneView() {
        sceneView.delegate = self
        #if DEBUG
        sceneView.showsStatistics = true
        #endif
    }
    
    func showTutorial() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Tutorial", bundle: nil)
        let next = storyboard.instantiateInitialViewController() as! PageViewController
        present(next, animated: true, completion: nil)
    }
    
    func resetTracking() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        sceneView.scene.rootNode.enumerateChildNodes { node, arg   in
            node.removeFromParentNode()
        }
        view.bringSubviewToFront(frameImageView)
        languageSegment.isEnabled = true
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
    
    func checkLocationAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            showLocationAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        }
    }
    
    func showLocationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("locationAlertTitle", comment: ""), message: NSLocalizedString("alertMessage", comment: ""), preferredStyle: .alert)
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
    
    func putStation(at position: SCNVector3, nodeName: String, textString: String) {
        var color = currentLine.color
        if nodeName == StationGetter.stationName {
            color = complementaryColor(baseColor: color)
        }
        putSphere(at: position, color: color, name: nodeName)
        let textPosition = SCNVector3(position.x, position.y, position.z + 0.02)
        putText(at: textPosition, name: textString)
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
            if let nodeName = hitResults[0].node.name {
                print(nodeName)
                if nodeName != StationGetter.stationName {
                    DestinationGetter.getLocation(destination: nodeName)
                    let routeView = SearchedRouteViewController()
                    routeView.destination = nodeName
                    routeView.currentLine = currentLine
                    present(routeView, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        sceneView.scene.rootNode.enumerateChildNodes { node, arg   in
            node.removeFromParentNode()
        }
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        guard let imageName = imageAnchor.referenceImage.name else { return }
        print(imageName)
        var segmentIndex: Int!
        DispatchQueue.main.sync {
            view.sendSubviewToBack(frameImageView)
            segmentIndex = self.languageSegment.selectedSegmentIndex
            languageSegment.isEnabled = false
        }
        currentLine = Line(rawValue: imageName)
        let baseX = anchor.transform.columns.3.x
        let baseY = anchor.transform.columns.3.y - 0.01
        let baseZ = anchor.transform.columns.3.z - 0.01
        let coordinateData = currentLine.coordinate
        let stationNames = Line.stationNames(currentLine, deviceLang)
        for i in 0..<stationNames[0].count {
            self.putStation(at: SCNVector3(baseX + coordinateData[i][0] * 3, baseY + coordinateData[i][1] * 3, baseZ), nodeName: stationNames[0][i], textString: stationNames[segmentIndex][i])
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        StationGetter.getStationName((locations.last?.coordinate)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization(status)
    }
}
