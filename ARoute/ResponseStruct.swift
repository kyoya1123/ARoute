import Foundation

struct ResponseData: Codable {
    var response: StationArray
}

struct StationArray: Codable {
    var station: [StationData]
}

struct StationData: Codable {
    var name: String
}
