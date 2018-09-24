import Foundation

func getCode(railName: String) {
    let urlString = "https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/station?APIKEY=6f4638646847384b557453786c3243746a5439512e4837672e5a315a4139634a737a392e76487476733441&railName=\(railName)"
    let encodedURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
    do {
        let json = try JSON(data: Data(contentsOf: encodedURL))
        var code = [String]()
        var name = [String]()
        for i in 0..<json["ResultSet"]["Point"].count {
            code.append(json["ResultSet"]["Point"][i]["Station"]["code"].string!)
            name.append(json["ResultSet"]["Point"][i]["Station"]["Name"].string!)
        }
        print(name, code, code.count)
    } catch {
        fatalError("RouteSearcher")
    }
}

getCode(railName: "東急田園都市線")
