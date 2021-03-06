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
    @IBOutlet var displayTypeSegment: UISegmentedControl!
    
    var locationManager: CLLocationManager!
    var currentLine: Line!
    
    override func viewDidLoad() {
        setupLocationManager()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
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

private extension ViewController {
    
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
        displayTypeSegment.addTarget(self, action: #selector(didchangeType), for: .valueChanged)
        if Language.deviceLang == .japanese {
            languageSegment.removeFromSuperview()
            return
        }
        let titles = Language.deviceLang.segmentTitle
        languageSegment.setTitle(titles[0], forSegmentAt: 0)
        languageSegment.setTitle(titles[1], forSegmentAt: 1)
        languageSegment.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Kano-regular", size: 15) ?? UIFont()], for: .normal)
    }
    
    @objc func didchangeType() {
        if displayTypeSegment.selectedSegmentIndex ==  1 {
            languageSegment.isEnabled = false
        } else {
            languageSegment.isEnabled = true
        }
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
    
    func putStation(at position: SCNVector3, nodeName: String, textString: String) {
        var color = currentLine.color
        if nodeName == StationGetter.stationName {
            color = color.complementaryColor
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
                    navigationController?.pushViewController(routeView, animated: true)
                }
            }
        }
    }
    
    func transitTo2DMap() {
        let mapVC = RouteMapViewController()
        mapVC.currentLine = currentLine
        navigationController?.pushViewController(mapVC, animated: true)
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        guard let imageName = imageAnchor.referenceImage.name else { return }
        currentLine = Line(rawValue: imageName)
        var segmentIndex: Int!
        var dispatchWorkItem:DispatchWorkItem?
        dispatchWorkItem = DispatchWorkItem {
            print("asdfjkasflkjasdf")
            self.sceneView.scene.rootNode.enumerateChildNodes { node, arg   in
                node.removeFromParentNode()
            }
            let baseX = anchor.transform.columns.3.x
            let baseY = anchor.transform.columns.3.y - 0.01
            let baseZ = anchor.transform.columns.3.z - 0.01
            let coordinateData = self.currentLine.coordinate
            let stationNames = self.currentLine.stationNames
            for i in 0..<stationNames[0].count {
                self.putStation(at: SCNVector3(baseX + coordinateData[i][0] * 3, baseY + coordinateData[i][1] * 3, baseZ), nodeName: stationNames[0][i], textString: stationNames[segmentIndex][i])
            }
        }
        DispatchQueue.main.sync {
            if displayTypeSegment.selectedSegmentIndex == 1 {
                transitTo2DMap()
                dispatchWorkItem?.cancel()
            }
            view.sendSubviewToBack(frameImageView)
            segmentIndex = self.languageSegment.selectedSegmentIndex
            languageSegment.isEnabled = false
        }
        DispatchQueue.global().async(execute: dispatchWorkItem!)
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
