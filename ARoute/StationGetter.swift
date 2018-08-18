import Foundation
import CoreLocation

class StationGetter {
    static func getStation(_ coordinate: CLLocationCoordinate2D) -> String? {
        let url = URL(string: "http://express.heartrails.com/api/json?method=getStations&x=\(coordinate.longitude)&y=\(coordinate.latitude)")
        let jsonData = try! Data(contentsOf: url!)
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(ResponseData.self, from: jsonData)
            let result = object.response.station[0].name
            return result
        }
        catch {
            print(error)
            return nil
        }
    }
}
