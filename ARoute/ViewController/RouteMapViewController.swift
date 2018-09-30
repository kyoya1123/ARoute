import UIKit

final class RouteMapViewController: UIViewController {
    
    @IBOutlet var stationTable: UITableView!
    
    var currentLine: Line!
    
    override func viewDidLoad() {
        setupView()
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
}

extension RouteMapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentLine.stationNames[0].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? RouteMapTableViewCell else { return UITableViewCell() }
        cell.colorView.backgroundColor = currentLine.color
        if currentLine.stationNames[0].index(of: StationGetter.stationName)! == indexPath.row {
            cell.colorView.backgroundColor = currentLine.color.complementaryColor
        }
        cell.stationNameLabel.text = currentLine.stationNames[0][indexPath.row]
        return cell
    }
}
