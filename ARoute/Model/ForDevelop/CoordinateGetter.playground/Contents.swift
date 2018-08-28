import UIKit

func getLineData(line: String) -> [[Float]] {
    let urlString = "http://express.heartrails.com/api/json?method=getStations&line=\(line)"
    let encodedURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
    let jsonData = try! Data(contentsOf: encodedURL)
    let decoder = JSONDecoder()
    do {
        let object = try decoder.decode(ResponseData.self, from: jsonData)
        var result = [[Float]]()
        object.response.station.forEach {
            result.append([$0.x, $0.y])
        }
        return result
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
    var x: Float
    var y: Float
}

func calculateCoordinate(result: [[Float]]) {
    var x = [Float]()
    var y = [Float]()
    result.forEach {
        x.append($0[0] )
        y.append($0[1] )
    }
    
    let centerX: Float = (x.max()! + x.min()!) / 2
    let centerY: Float = (y.max()! + y.min()!) / 2
    
    var newCoordinate = [[Any]]()
    result.forEach {
        newCoordinate.append([$0[0] - centerX, $0[1] - centerY])
    }
    print(newCoordinate)
}

calculateCoordinate(result: getLineData(line: "東京メトロ銀座線"))
//銀座, 山手, 総武, 中央, 東横, 田園都市, 東西線,
