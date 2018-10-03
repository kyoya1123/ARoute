import UIKit

final class RouteMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var closeButton: UIBarButtonItem!
    @IBOutlet var stationTable: UITableView!
    
    var currentLine: Line!
    
    override func viewDidLoad() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
        if let selectedRow = stationTable.indexPathForSelectedRow {
            stationTable.deselectRow(at: selectedRow, animated: true)
        }
    }
}

private extension RouteMapViewController {
    func setupView() {
        setupTableView()
    }
    
    func setupTableView() {
        stationTable.delegate = self
        stationTable.dataSource = self
        stationTable.register(UINib(nibName: "RouteMapTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    func setupNavigationBar() {
        setupButton()
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = true
        navigationItem.setLeftBarButton(closeButton, animated: false)
    }
    
    func setupButton() {
        let tmpClose = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        tmpClose.setImage(UIImage(named: "back"), for: .normal)
        tmpClose.addTarget(self, action: #selector(didtapClose), for: .touchUpInside)
        closeButton = UIBarButtonItem(customView: tmpClose)
        closeButton.customView?.widthAnchor.constraint(equalToConstant: 35).isActive = true
        closeButton.customView?.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    @objc func didtapClose() {
        navigationController?.popViewController(animated: true)
    }
}

extension RouteMapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentLine.stationNames[0].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? RouteMapTableViewCell else { return UITableViewCell() }
        cell.colorView.backgroundColor = currentLine.color
        if Language.deviceLang == .japanese {
            cell.stationNameLabel.text = currentLine.stationNames[0][indexPath.row]
        } else {
            cell.stationNameLabel.text = "\(currentLine.stationNames[1][indexPath.row])(\(currentLine.stationNames[0][indexPath.row]))"
        }
        if currentLine.stationNames[0].index(of: StationGetter.stationName)! == indexPath.row {
            cell.colorView.backgroundColor = currentLine.color.complementaryColor
            cell.selectionStyle = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == currentLine.stationNames[0].index(of: StationGetter.stationName)! { return }
        let routeView = SearchedRouteViewController()
        routeView.destination = currentLine.stationNames[0][indexPath.row]
        routeView.currentLine = currentLine
        navigationController?.pushViewController(routeView, animated: true)
    }
}
