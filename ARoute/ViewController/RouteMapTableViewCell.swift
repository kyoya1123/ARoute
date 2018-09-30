import UIKit

final class RouteMapTableViewCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var stationNameLabel: UILabel!
    
    override func layoutSubviews() {
        colorView.layer.cornerRadius = colorView.frame.height / 2
        colorView.layer.masksToBounds = true
    }
}
