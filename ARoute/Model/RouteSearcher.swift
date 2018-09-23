import Foundation

class RouteSearcher {
    
    static var searchResult = [String : String]()
    
    static func search(destination: String) {
        searchResult.removeAll()
        let urlString = "https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/searchCourseExtreme?APIKEY=6f4638646847384b557453786c3243746a5439512e4837672e5a315a4139634a737a392e76487476733441&viaList=\(StationGetter.stationName):\(destination)&sort=transfer"
        let encodedURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        let jsonData = try! Data(contentsOf: encodedURL)
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(RouteSearchResponse.self, from: jsonData)
            assignResult(object)
        } catch {
            print("error")
        }
    }
    
    private static func assignResult(_ object: RouteSearchResponse) {
        let route = object.ResultSet.Course[0].Route
        searchResult["destination"] = route.Line.Destination
        searchResult["duration"] = formatDuration(route.timeOnBoard)
        searchResult["platform"] = route.Line.DepartureState.no
        searchResult["departure"] = formatDatetime(route.Line.DepartureState.Datetime.text)
        searchResult["arrival"] = formatDatetime(route.Line.ArrivalState.Datetime.text)
    }
    
    private static func formatDuration(_ duration: String) -> String {
        let durationInt = Int(duration)!
        if durationInt >= 60 {
            let hour = durationInt / 60
            let min = durationInt - hour
            return "\(hour)h\(min)m"
        } else {
            return duration + "m"
        }
    }
    
    private static func formatDatetime(_ datetime: String) -> String {
        return String(datetime[datetime.index(datetime.startIndex, offsetBy: 11)..<datetime.index(datetime.startIndex, offsetBy: 16)])
    }
}
