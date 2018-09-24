import Foundation

class RouteSearcher {
    
    static var searchResult = [String : String]()
    
    static func search(destination: String) {
        let urlString = "https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/searchCourseExtreme?APIKEY=6f4638646847384b557453786c3243746a5439512e4837672e5a315a4139634a737a392e76487476733441&viaList=22787:22849&sort=transfer"
        let encodedURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        do {
            let json = try JSON(data: Data(contentsOf: encodedURL))
            assignResult(json)
        } catch {
            fatalError("RouteSearcher")
        }
    }
    
    private static func assignResult(_ json: JSON) {
        let route = json["ResultSet"]["Course"][0]["Route"]
        searchResult["duration"] = formatDuration(route["timeOnBoard"].string!)
        searchResult["platform"] = route["Line"]["DepartureState"]["no"].string
        searchResult["departure"] = formatDatetime(route["Line"]["DepartureState"]["Datetime"]["text"].string!)
        searchResult["arrival"] = formatDatetime(route["Line"]["ArrivalState"]["Datetime"]["text"].string!)
    }
    
    private static func formatDuration(_ duration: String) -> String {
        let durationInt = Int(duration)!
        if durationInt >= 60 {
            let hour = durationInt / 60
            let min = durationInt - hour
            return "\(hour)\(NSLocalizedString("hour", comment: ""))\(min)\(NSLocalizedString("minute", comment: ""))"
        } else {
            return duration + NSLocalizedString("minute", comment: "")
        }
    }
    
    private static func formatDatetime(_ datetime: String) -> String {
        return String(datetime[datetime.index(datetime.startIndex, offsetBy: 11)..<datetime.index(datetime.startIndex, offsetBy: 16)])
    }
}
