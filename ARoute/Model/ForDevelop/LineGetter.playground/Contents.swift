import Foundation

func getLineData(line: String) {
    let urlString = "http://express.heartrails.com/api/json?method=getStations&line=\(line)"
    let encodedURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
    let jsonData = try! Data(contentsOf: encodedURL)
    let decoder = JSONDecoder()
    do {
        let object = try decoder.decode(ResponseData.self, from: jsonData)
        var result = [String]()
        object.response.station.forEach {
            result.append($0.name)
        }
        print(result)
    } catch {
        fatalError("LineGetter")
    }
}

struct ResponseData: Codable {
    var response: StationArray
}

struct StationArray: Codable {
    var station: [StationData]
}

struct StationData: Codable {
    var name: String
}

let lineNames = ["JR山手線", "JR総武線", "JR中央線", "東急田園都市線", "東急東横線", "東京メトロ丸ノ内線","東京メトロ丸ノ内分岐線", "東京メトロ銀座線", "東京メトロ東西線"]
getLineData(line: lineNames[2])

