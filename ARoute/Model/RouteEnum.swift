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
    
    func stations() -> [String] {
        switch self {
        case .yamanote:
            return ["東京","有楽町","新橋","浜松町","田町","品川","大崎","五反田","目黒","恵比寿","渋谷","原宿","代々木","新宿","新大久保","高田馬場","目白","池袋","大塚","巣鴨","駒込","田端","西日暮里","日暮里","鶯谷","上野","御徒町","秋葉原","神田"]
        case .soubu:
            return []
        case .tyuuou:
            return []
        case .dennenntoshi:
            return []
        case .touyoko:
            return []
        }
    }
}
