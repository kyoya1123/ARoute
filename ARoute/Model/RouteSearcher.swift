import Foundation
import UIKit

class RouteSearcher {
    
    static var searchResult = [String]()
    
    static func scrape(destination: String) {
        let doc = Ji(htmlURL: RouteSearcher.prepareURL(destination: destination))
        let xPaths = ["//*[@id='left_pane']/ol[1]/li[1]/dl/dt",//出発到着時刻
            "//*[@id='detail_route_0']/div[1]/div[2]/dl/dd",//所要時間
            "//*[@id='detail_route_0']/div[3]/div[2]/div[2]/ul/li",
            "//*[@id='detail_route_0']/div[3]/div[3]/div[2]/ul/li"]//何番線発
        //////////
        ////////            //*[@id="detail_route_0"]/div[3]/div[2]/div[2]/dl/dt
        /////////
        var tmpArray = [String]()
        for xPath in xPaths {
            let scrapedText = doc?.xPath(xPath)?.first?.content
            let trimmedText = scrapedText?.trimmingCharacters(in: .whitespacesAndNewlines)
            tmpArray.append(trimmedText ?? "")
        }
        searchResult.append(String((tmpArray[0].prefix(5))))
        searchResult.append(String((tmpArray[0].suffix(5))))
        var replacedString = tmpArray[1].replacingOccurrences(of: "分", with: "m")
        if tmpArray[1].count > 3 {
            replacedString = replacedString.replacingOccurrences(of: "時間", with: "h")
        }
        searchResult.append(replacedString)
        var terminal: String!
        if tmpArray[2] != "" {
            terminal = tmpArray[2]
        } else {
            terminal = tmpArray[3]
        }
        searchResult.append(terminal.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined().applyingTransform(.fullwidthToHalfwidth, reverse: false)!)
    }
    
    private static func prepareURL(destination: String) -> URL {
        let splitDate = prepareSplitDate()
        let urlString = "https://www.navitime.co.jp/transfer/searchlist?orvStationName=\(StationGetter.stationName)&dnvStationName=\(destination)&thrStationName1=&thrStationCode1=&thrStationName2=&thrStationCode2=&thrStationName3=&thrStationCode3=&month=\(splitDate[0])%2F\(splitDate[1])&day=\(splitDate[2])&hour=\(splitDate[3])&minute=\(splitDate[4])&orvStationCode=&dnvStationCode=&basis=1&from=view.transfer.top&sort=2&wspeed=100&airplane=1&sprexprs=1&utrexprs=1&othexprs=1&mtrplbus=1&intercitybus=1&ferry=1&ctl=020010&atr=2&init="
        let encodedURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        print(encodedURL)
        return encodedURL
    }
    
    private static func prepareSplitDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy,MM,dd,hh,mm"
        let dateString = formatter.string(from: Date())
        return dateString.components(separatedBy: ",")
    }
}
