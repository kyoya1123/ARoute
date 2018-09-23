import Foundation

//MARK: StationGetter, DestinationGetter
struct ResponseData: Codable {
    var response: StationArray
}

struct StationArray: Codable {
    var station: [StationData]
}

struct StationData: Codable {
    var name: String
    var x: Double
    var y: Double
}


//MARK: RouteSearcher
struct RouteSearchResponse: Codable {
    var ResultSet: ResultSet
}

struct ResultSet: Codable {
    var Course: [CourseArray]
}

struct CourseArray: Codable {
    var Route: RouteData
}

struct RouteData: Codable {
    var timeOnBoard: String
    var Line: LineData
}

struct LineData: Codable {
    var Destination: String
    var DepartureState: DepartureState
    var ArrivalState: ArrivalState
}

struct ArrivalState: Codable {
    var Datetime: Datetime
}

struct DepartureState: Codable {
    var no: String
    var Datetime: Datetime
}

struct Datetime: Codable {
    var text: String
}
