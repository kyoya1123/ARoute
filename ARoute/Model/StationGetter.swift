import CoreLocation

final class StationGetter {
    
    static var nearestStation = ""
    
    static func getStationName(_ coordinate: CLLocationCoordinate2D) {
        let url = URL(string: "http://express.heartrails.com/api/json?method=getStations&x=\(coordinate.longitude)&y=\(coordinate.latitude)")
        let jsonData = try! Data(contentsOf: url!)
        let decoder = JSONDecoder()
        
        do {
            let object = try decoder.decode(ResponseData.self, from: jsonData)
            let result = object.response.station[0].name
//            nearestStation = result
            nearestStation = "東中野"
            print(result)
        }
        catch {
            fatalError("JSON decode error")
        }
    }
}
