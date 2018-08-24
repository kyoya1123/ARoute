import Foundation
import CoreLocation

class DestinationGetter {
    
    static var coordinate = CLLocationCoordinate2D()
    
    static func getLocation(destination: String) {
        DispatchQueue.global().async {
            let urlString = "http://express.heartrails.com/api/json?method=getStations&name=\(destination)"
            let encodedURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
            let jsonData = try! Data(contentsOf: encodedURL)
            let decoder = JSONDecoder()
            do {
                let object = try decoder.decode(ResponseData.self, from: jsonData)
                coordinate = CLLocationCoordinate2D(latitude: object.response.station[0].y, longitude: object.response.station[1].x)
                print(coordinate)
            } catch {
                fatalError("DestinationGetter")
            }
        }
    }
}
