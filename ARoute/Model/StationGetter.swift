import CoreLocation

final class StationGetter {
    
    static var stationName = ""
    
    static func getStationName(_ coordinate: CLLocationCoordinate2D) {
        DispatchQueue.global().async {
            let url = URL(string: "http://express.heartrails.com/api/json?method=getStations&x=\(coordinate.longitude)&y=\(coordinate.latitude)")
            let jsonData = try! Data(contentsOf: url!)
            let decoder = JSONDecoder()
            
            do {
                let object = try decoder.decode(ResponseData.self, from: jsonData)
                let result = object.response.station[0].name
                //            nearestStation = result
                stationName = "新宿"
                print(result)
            }
            catch {
                fatalError("StationGetter")
            }
        }
    }
}
