import Foundation

enum Language: String {
    case english = "en"
    case chinese = "zh"
    case korean = "ko"
    case japanese = "ja"
    
    static func segmentTitle(_ language: Language) -> [String] {
        switch language {
        case .english:
            return ["Japanese", "English"]
        case .chinese:
            return ["日本语", "中国语"]
        case .korean:
            return ["일본어", "한국어"]
        case .japanese:
            return []
        }
    }
}
