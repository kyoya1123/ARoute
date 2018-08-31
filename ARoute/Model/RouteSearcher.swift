import Foundation
import UIKit

class RouteSearcher {
    
    static var searchResult = [String]()
    
    static func scrape(destination: String) {
        searchResult.removeAll()
        let doc = Ji(htmlURL: RouteSearcher.prepareURL(destination: destination))
        let xPaths = ["//*[@id='left_pane']/h1/strong[2]",//destination
            "//*[@id='left_pane']/ol[1]/li[1]/dl/dt", //time
            "//*[@id='detail_route_0']/div[1]/div[2]/dl/dd", //duration
            "//*[@id='detail_route_0']/div[3]/div[2]/ul/li[1]",//duration
            "//*[@id='detail_route_0']/div[3]/div[2]/div[2]/ul/li",//platform
            "//*[@id='detail_route_0']/div[3]/div[3]/div[2]/ul/li"]//platform
        var tmpArray = [String]()
        for xPath in xPaths {
            let scrapedText = doc?.xPath(xPath)?.first?.content
            let trimmedText = scrapedText?.trimmingCharacters(in: .whitespacesAndNewlines)
            tmpArray.append(trimmedText ?? "")
        }
        searchResult.append(tmpArray[0])
        searchResult.append(String((tmpArray[1].prefix(5))))
        searchResult.append(String((tmpArray[1].suffix(5))))
        if tmpArray[2] != "" {
            searchResult.append(tmpArray[2])
        } else {
            searchResult.append(tmpArray[3])
        }
        var terminal: String!
        if tmpArray[4] != "" {
            terminal = tmpArray[4]
        } else {
            terminal = tmpArray[5]
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
