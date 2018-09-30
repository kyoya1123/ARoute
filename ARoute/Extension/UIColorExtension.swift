import UIKit

extension UIColor {
    var complementaryColor: UIColor {
        let ciColor = CIColor(color: self)
        let compRed = 1 - ciColor.red
        let compGreen = 1 - ciColor.green
        let compBlue = 1 - ciColor.blue
        return UIColor(red: compRed, green: compGreen, blue: compBlue, alpha: 1)
    }
}
