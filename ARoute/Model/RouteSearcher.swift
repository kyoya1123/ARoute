import Foundation
import UIKit

class RouteSearcher {
    
    static var searchResult = [String]()
    
    static func scrape(destination: String) {
        let doc = Ji(htmlURL: prepareURL(destination: destination))
        let xPaths = ["//*[@id='left_pane']/ol[1]/li[1]/dl/dt",//出発到着時刻
            "//*[@id='detail_route_0']/div[1]/div[2]/dl/dd",//所要時間
            "//*[@id='detail_route_0']/div[3]/div[2]/div[2]/ul/li"]//何番線発
        var routeSearchResult = [String]()
        for xPath in xPaths {
            let scrapedText = doc?.xPath(xPath)?.first?.content
            let trimmedText = scrapedText?.trimmingCharacters(in: .whitespacesAndNewlines)
            if routeSearchResult.count == 0 {
                routeSearchResult.append(String((trimmedText?.prefix(5))!))
                routeSearchResult.append(String((trimmedText?.suffix(5))!))
                continue
            }
            routeSearchResult.append(trimmedText!)
        }
        routeSearchResult[2] = String(routeSearchResult[2].dropLast())
        routeSearchResult[3] = routeSearchResult[3].prefix(1).applyingTransform(.fullwidthToHalfwidth, reverse: false)!
        print(routeSearchResult)
        searchResult = routeSearchResult
    }
    
    private static func prepareURL(destination: String) -> URL {
        let splitDate = prepareSplitDate()
        let urlString = "https://www.navitime.co.jp/transfer/searchlist?orvStationName=\(StationGetter.stationName)&dnvStationName=\(destination)&thrStationName1=&thrStationCode1=&thrStationName2=&thrStationCode2=&thrStationName3=&thrStationCode3=&month=\(splitDate[0])%2F\(splitDate[1])&day=\(splitDate[2])&hour=\(splitDate[3])&minute=\(splitDate[4])&orvStationCode=&dnvStationCode=&basis=1&from=view.transfer.top&sort=2&wspeed=100&airplane=1&sprexprs=1&utrexprs=1&othexprs=1&mtrplbus=1&intercitybus=1&ferry=1&ctl=020010&atr=2&init="
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
    }
    
    private static func prepareSplitDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy,MM,dd,hh,mm"
        let dateString = formatter.string(from: Date())
        return dateString.components(separatedBy: ",")
    }
}
