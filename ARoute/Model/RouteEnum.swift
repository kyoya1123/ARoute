import UIKit

enum Route {
    case yamanote
    case soubu
    case tyuuou
    case dennenntoshi
    case touyoko
    
    static var currentRoute = Route.yamanote
    
    init?(name: String) {
        switch name {
        case "yamanote":
            self = .yamanote
        case "soubu":
            self = .soubu
        case "tyuuou":
            self = .tyuuou
        case "dennenntoshi":
            self = .dennenntoshi
        case "touyoko":
            self = .touyoko
        default: return nil
        }
        Route.currentRoute = self
    }
    
    func color() -> UIColor {
        switch self {
        case .yamanote:
            return #colorLiteral(red: 0.6941176471, green: 0.7882352941, blue: 0.2745098039, alpha: 1)
        case .soubu:
            return #colorLiteral(red: 0.9450980392, green: 0.8078431373, blue: 0.2235294118, alpha: 1)
        case .tyuuou:
            return #colorLiteral(red: 0.8588235294, green: 0.4117647059, blue: 0.2392156863, alpha: 1)
        case .dennenntoshi:
            return #colorLiteral(red: 0.09803921569, green: 0.662745098, blue: 0.5529411765, alpha: 1)
        case .touyoko:
            return #colorLiteral(red: 0.8392156863, green: 0.04705882353, blue: 0.2705882353, alpha: 1)
        }
    }
}
