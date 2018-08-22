import UIKit

enum Route {
    case yamanote
    case soubu
    case tyuuou
    case dennenntoshi
    case touyoko
    
    static var currentRoute = Route.yamanote
    static var stations = [String]()
    static var color = UIColor()
    
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
        assignStations()
        assignColor()
    }
    
    private func assignColor() {
        switch Route.currentRoute {
        case .yamanote:
            Route.color = #colorLiteral(red: 0.6941176471, green: 0.7882352941, blue: 0.2745098039, alpha: 1)
        case .soubu:
            Route.color = #colorLiteral(red: 0.9450980392, green: 0.8078431373, blue: 0.2235294118, alpha: 1)
        case .tyuuou:
            Route.color = #colorLiteral(red: 0.8588235294, green: 0.4117647059, blue: 0.2392156863, alpha: 1)
        case .dennenntoshi:
            Route.color = #colorLiteral(red: 0.09803921569, green: 0.662745098, blue: 0.5529411765, alpha: 1)
        case .touyoko:
            Route.color = #colorLiteral(red: 0.8392156863, green: 0.04705882353, blue: 0.2705882353, alpha: 1)
        }
    }
    
    private func assignStations() {
        switch Route.currentRoute {
        case .yamanote:
            Route.stations = ["東京","有楽町","新橋","浜松町","田町","品川","大崎","五反田","目黒","恵比寿","渋谷","原宿","代々木","新宿","新大久保","高田馬場","目白","池袋","大塚","巣鴨","駒込","田端","西日暮里","日暮里","鶯谷","上野","御徒町","秋葉原","神田"]
        case .soubu:
            Route.stations = ["三鷹","吉祥寺","西荻窪","荻窪","阿佐ヶ谷","高円寺","中野","東中野","大久保","新宿","代々木","千駄ヶ谷","信濃町","四ッ谷","市ヶ谷","飯田橋","水道橋","御茶ノ水","秋葉原","浅草橋","両国","錦糸町","亀戸","平井","新小岩","小岩","市川","本八幡","下総中山","西船橋","船橋","東船橋","津田沼","幕張本郷","幕張","新検見川","稲毛","西千葉","千葉"]
        case .tyuuou:
            Route.stations = []
        case .dennenntoshi:
            Route.stations = []
        case .touyoko:
            Route.stations = []
        }
    }
}
