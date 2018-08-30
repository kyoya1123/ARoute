import UIKit

enum Line: String {
    case yamanote = "yamanote"
    case soubu = "soubu"
    case tyuuou = "tyuuou"
    case dennenntoshi = "dennenntoshi"
    case touyoko = "touyoko"
    case marunouchi = "marunouchi"
    case ginza = "ginza"
    case touzai = "touzai"
    
    static func color(_ line: Line) -> UIColor {
        switch line {
        case .yamanote:
            return #colorLiteral(red: 0.6941176471, green: 0.7882352941, blue: 0.2745098039, alpha: 1)
        case .soubu:
            return #colorLiteral(red: 0.9450980392, green: 0.8078431373, blue: 0.2235294118, alpha: 1)
        case .tyuuou:
            return #colorLiteral(red: 0.8588235294, green: 0.4117647059, blue: 0.2392156863, alpha: 1)
        case .dennenntoshi:
            return #colorLiteral(red: 0.09803921569, green: 0.662745098, blue: 0.5529411765, alpha: 1)
        case .touyoko:
            return #colorLiteral(red: 0.8392156863, green: 0.04705882353, blue: 0.2705882353, alpha: 1)
        case .marunouchi:
            return #colorLiteral(red: 0.9529411765, green: 0.1882352941, blue: 0.2392156863, alpha: 1)
        case .ginza:
            return #colorLiteral(red: 0.9921568627, green: 0.5764705882, blue: 0.1490196078, alpha: 1)
        case .touzai:
            return #colorLiteral(red: 0.09411764706, green: 0.6078431373, blue: 0.737254902, alpha: 1)
        }
    }
    
    static func stationNames(_ line: Line, _ language: Language) -> [[String]] {
        return [japaneseNames(line), secondLanguageNames(line, language)]
    }
    
    private static func secondLanguageNames(_ line: Line, _ language: Language) -> [String] {
        switch language {
        case .japanese:
            return []
        case .english:
            return englishNames(line)
        case .chinese:
            return chineseNames(line)
        case .korean:
            return koreanNames(line)
        }
    }
    
    private static func japaneseNames(_ line: Line) -> [String] {
        switch line {
        case .yamanote:
            return
                ["品川", "大崎", "五反田", "目黒", "恵比寿", "渋谷", "原宿", "代々木", "新宿", "新大久保", "高田馬場", "目白", "池袋", "大塚", "巣鴨", "駒込", "田端", "西日暮里", "日暮里", "鶯谷", "上野", "御徒町", "秋葉原", "神田", "東京", "有楽町", "新橋", "浜松町", "田町"]
        case .soubu:
            return
                ["三鷹", "吉祥寺", "西荻窪", "荻窪", "阿佐ケ谷", "高円寺", "中野", "東中野", "大久保", "新宿", "代々木", "千駄ケ谷", "信濃町", "四ツ谷", "市ヶ谷", "飯田橋", "水道橋", "御茶ノ水", "秋葉原", "浅草橋", "両国", "錦糸町", "亀戸", "平井", "新小岩", "小岩", "市川", "本八幡", "下総中山", "西船橋", "船橋", "東船橋", "津田沼", "幕張本郷", "幕張", "新検見川", "稲毛", "西千葉", "千葉"]
        case .tyuuou:
            return
                ["東京", "神田", "御茶ノ水", "水道橋", "飯田橋", "市ケ谷", "四ツ谷", "信濃町", "千駄ケ谷", "代々木", "新宿", "大久保", "東中野", "中野", "高円寺", "阿佐ケ谷", "荻窪", "西荻窪", "吉祥寺", "三鷹", "武蔵境", "東小金井", "武蔵小金井", "国分寺", "西国分寺", "国立", "立川", "日野", "豊田", "八王子", "西八王子", "高尾"]
        case .dennenntoshi:
            return
                ["渋谷", "池尻大橋", "三軒茶屋", "駒沢大学", "桜新町", "用賀", "二子玉川", "二子新地", "高津", "溝の口", "梶が谷", "宮崎台", "宮前平", "鷺沼", "たまプラーザ", "あざみ野", "江田", "市が尾", "藤が丘", "青葉台", "田奈", "長津田", "つくし野", "すずかけ台", "南町田", "つきみ野", "中央林間"]
        case .touyoko:
            return
                ["渋谷", "代官山", "中目黒", "祐天寺", "学芸大学", "都立大学", "自由が丘", "田園調布", "多摩川", "新丸子", "武蔵小杉", "元住吉", "日吉", "綱島", "大倉山", "菊名", "妙蓮寺", "白楽", "東白楽", "反町", "横浜"]
        case .marunouchi:
            return
                ["池袋", "新大塚", "茗荷谷", "後楽園", "本郷三丁目", "御茶ノ水", "淡路町", "大手町", "東京", "銀座", "霞ケ関", "国会議事堂前", "赤坂見附", "四ツ谷", "四谷三丁目", "新宿御苑前", "新宿三丁目", "新宿", "西新宿", "中野坂上", "新中野", "東高円寺", "新高円寺", "南阿佐ヶ谷", "荻窪", "中野新橋", "中野富士見町", "方南町"]
        case .ginza:
            return
                ["渋谷", "表参道", "外苑前", "青山一丁目", "赤坂見附", "溜池山王", "虎ノ門", "新橋", "銀座", "京橋", "日本橋", "三越前", "神田", "末広町", "上野広小路", "上野", "稲荷町", "田原町", "浅草"]
        case .touzai:
            return
                ["中野", "落合", "高田馬場", "早稲田", "神楽坂", "飯田橋", "九段下", "竹橋", "大手町", "日本橋", "茅場町", "門前仲町", "木場", "東陽町", "南砂町", "西葛西", "葛西", "浦安", "南行徳", "行徳", "妙典", "原木中山", "西船橋"]
        }
    }
    
    private static func englishNames(_ line: Line) -> [String] {
        switch line {
        case .yamanote:
            return
                ["Shinagawa", "Ōsaki", "Gotanda", "Meguro", "Ebisu", "Shibuya", "Harajuku", "Yoyogi", "Shinjuku", "Shin-Ōkubo", "Takadanobaba", "Mejiro", "Ikebukuro", "Ōtsuka", "Sugamo", "Komagome", "Tabata", "Nishi-Nippori", "Nippori", "Uguisudani", "Ueno", "Okachimachi", "Akihabara", "Kanda", "Tokyo", "Yūrakuchō", "Shimbashi", "Hamamatsuchō", "Tamachi"]
        case .soubu:
            return
                []
        case .tyuuou:
            return
                []
        case .dennenntoshi:
            return
                []
        case .touyoko:
            return
                []
        case .marunouchi:
            return
                []
        case .ginza:
            return
                []
        case .touzai:
            return
                []
        }
    }
    
    private static func chineseNames(_ line: Line) -> [String] {
        switch line {
        case .yamanote:
            return
                []
        case .soubu:
            return
                []
        case .tyuuou:
            return
                []
        case .dennenntoshi:
            return
                []
        case .touyoko:
            return
                []
        case .marunouchi:
            return
                []
        case .ginza:
            return
                []
        case .touzai:
            return
                []
        }
    }
    
    private static func koreanNames(_ line: Line) -> [String] {
        switch line {
        case .yamanote:
            return
                []
        case .soubu:
            return
                []
        case .tyuuou:
            return
                []
        case .dennenntoshi:
            return
                []
        case .touyoko:
            return
                []
        case .marunouchi:
            return
                []
        case .ginza:
            return
                []
        case .touzai:
            return
                []
        }
    }
    
    static func coordinate(_ line: Line) -> [[Float]] {
        switch line {
        case .yamanote:
            return
                [[-0.0001373291, -0.05001831], [-0.010696411, -0.059005737], [-0.015319824, -0.052806854], [-0.023361206, -0.044857025], [-0.029067993, -0.032096863], [-0.037902832, -0.019908905], [-0.0365448, -0.008132935], [-0.037094116, 0.0042800903], [-0.03866577, 0.010948181], [-0.038879395, 0.022094727], [-0.03541565, 0.0338974], [-0.032913208, 0.04169464], [-0.028045654, 0.051475525], [-0.010559082, 0.05263138], [0.00016784668, 0.05466461], [0.008911133, 0.058044434], [0.022094727, 0.059001923], [0.02772522, 0.053173065], [0.03215027, 0.049129486], [0.038879395, 0.042705536], [0.037902832, 0.03501129], [0.035598755, 0.028503418], [0.03414917, 0.01984024], [0.0315094, 0.012393951], [0.02696228, 0.0026130676], [0.024673462, -0.00333786], [0.019454956, -0.012584686], [0.018005371, -0.023387909], [0.00843811, -0.033042908]]
        case .soubu:
            return
                [[-0.27626038, 0.02936554], [-0.25682068, 0.029800415], [-0.23721313, 0.030525208], [-0.21647644, 0.031204224], [-0.20071411, 0.03150177], [-0.18692017, 0.032009125], [-0.17074585, 0.032447815], [-0.15214539, 0.033210754], [-0.13925171, 0.02746582], [-0.1361084, 0.016410828], [-0.13453674, 0.009742737], [-0.124938965, 0.007915497], [-0.11584473, 0.006713867], [-0.10594177, 0.01272583], [-0.1007843, 0.019275665], [-0.091430664, 0.028518677], [-0.08226013, 0.028720856], [-0.071624756, 0.026287079], [-0.06329346, 0.025302887], [-0.05215454, 0.024085999], [-0.04324341, 0.022472382], [-0.022445679, 0.023483276], [-0.010314941, 0.024028778], [0.0055999756, 0.033111572], [0.021194458, 0.04358673], [0.045181274, 0.059890747], [0.07156372, 0.05558777], [0.09083557, 0.04758072], [0.10650635, 0.040958405], [0.12295532, 0.033966064], [0.14813232, 0.028549194], [0.1673584, 0.026493073], [0.18359375, 0.018051147], [0.20565796, -0.00065231323], [0.22132874, -0.013916016], [0.2364502, -0.021625519], [0.25598145, -0.036052704], [0.26675415, -0.050678253], [0.27626038, -0.059890747]]
        case .tyuuou:
            return
                [[0.23963928, 0.0071144104], [0.2441864, 0.016895294], [0.23849487, 0.025325775], [0.2278595, 0.027759552], [0.21868896, 0.027557373], [0.20878601, 0.01682663], [0.20417786, 0.011764526], [0.1942749, 0.0057525635], [0.18518066, 0.006954193], [0.17558289, 0.008781433], [0.17401123, 0.015449524], [0.17086792, 0.026504517], [0.15797424, 0.03224945], [0.13937378, 0.03148651], [0.12319946, 0.031047821], [0.10940552, 0.030540466], [0.09364319, 0.03024292], [0.072906494, 0.029563904], [0.05329895, 0.028839111], [0.033859253, 0.028404236], [0.016937256, 0.027805328], [-0.0016174316, 0.027366638], [-0.019973755, 0.027057648], [-0.04562378, 0.025844574], [-0.06047058, 0.025466919], [-0.0801239, 0.024951935], [-0.11274719, 0.023921967], [-0.13252258, 0.004966736], [-0.1449585, -0.014778137], [-0.18745422, -0.018722534], [-0.21382141, -0.017658234], [-0.24417114, -0.032253265]]
        case .dennenntoshi:
            return
                [[0.12860107, 0.075172424], [0.11077881, 0.06775665], [0.09660339, 0.06086731], [0.088150024, 0.050624847], [0.07122803, 0.04881668], [0.06037903, 0.04358673], [0.053131104, 0.028942108], [0.048797607, 0.024147034], [0.043380737, 0.020401001], [0.03694153, 0.016990662], [0.032333374, 0.011116028], [0.01776123, 0.0043792725], [0.00843811, 0.0021018982], [-0.0002746582, -0.00308609], [-0.015106201, -0.005420685], [-0.020080566, -0.014202118], [-0.022033691, -0.024177551], [-0.032058716, -0.03136444], [-0.045898438, -0.03939438], [-0.056167603, -0.039993286], [-0.06869507, -0.046642303], [-0.08000183, -0.05088806], [-0.088409424, -0.055290222], [-0.09185791, -0.06575394], [-0.10322571, -0.07134628], [-0.11489868, -0.07229996], [-0.12861633, -0.07517624]]
        case .touyoko:
            return
                [[0.039642334, 0.096588135], [0.040496826, 0.085235596], [0.035842896, 0.08089447], [0.02798462, 0.07420349], [0.022445679, 0.065826416], [0.01361084, 0.054878235], [0.0058898926, 0.044265747], [0.0045776367, 0.03385544], [0.005935669, 0.026634216], [-0.0008239746, 0.017532349], [-0.0031280518, 0.012794495], [-0.008117676, 0.0027389526], [-0.015838623, -0.009056091], [-0.027877808, -0.026050568], [-0.032974243, -0.040527344], [-0.031417847, -0.0531044], [-0.029586792, -0.06417847], [-0.03491211, -0.073402405], [-0.033416748, -0.07943344], [-0.03744507, -0.08821869], [-0.040481567, -0.09658432]]
        case .marunouchi:
            return
                [[0.017242432, 0.029132843], [0.036117554, 0.02456665], [0.04333496, 0.015865326], [0.058013916, 0.0067749023], [0.06607056, 0.0055503845], [0.07009888, -0.00050735474], [0.07373047, -0.0056877136], [0.07235718, -0.014556885], [0.07086182, -0.019371033], [0.070114136, -0.029132843], [0.057052612, -0.027282715], [0.051376343, -0.027191162], [0.04319763, -0.024101257], [0.036102295, -0.016536713], [0.026260376, -0.01316452], [0.016845703, -0.012535095], [0.011047363, -0.010276794], [0.006866455, -0.008773804], [-0.0010681152, -0.0068244934], [-0.010940552, -0.003200531], [-0.024810791, -0.0036315918], [-0.036026, -0.0033187866], [-0.045776367, -0.0031356812], [-0.05809021, -0.001499176], [-0.07373047, 0.0031814575], [0.013198853, 0.0072135925], [0.0042877197, 0.0014152527], [-0.0027770996, -0.00019454956], [-0.013214111, -0.0072135925]]
        case .ginza:
            return
                [[-0.048294067, -0.02620697], [-0.036987305, -0.020023346], [-0.031448364, -0.014743805], [-0.025146484, -0.012508392], [-0.012252808, -0.00825119], [-0.007873535, -0.011650085], [0.0005340576, -0.015037537], [0.009140015, -0.017837524], [0.014663696, -0.013282776], [0.020828247, -0.008415222], [0.024215698, -0.0031929016], [0.024291992, 0.00182724], [0.021606445, 0.00831604], [0.022415161, 0.017700195], [0.02357483, 0.022407532], [0.027816772, 0.026210785], [0.033294678, 0.026000977], [0.04159546, 0.02462387], [0.048294067, 0.02545929]]
        case .touzai:
            return
                [[-0.14657593, 0.017318726], [-0.12512207, 0.022529602], [-0.107666016, 0.0248909], [-0.09109497, 0.017276764], [-0.0778656, 0.015342712], [-0.06642151, 0.013278961], [-0.060455322, 0.0071411133], [-0.05558777, 0.002216339], [-0.046325684, -0.0036468506], [-0.038894653, -0.0063667297], [-0.032409668, -0.008693695], [-0.016204834, -0.016593933], [-0.0053710938, -0.019096375], [0.0051879883, -0.018817902], [0.018234253, -0.019649506], [0.046844482, -0.023815155], [0.060043335, -0.0248909], [0.08078003, -0.022514343], [0.089904785, -0.015758514], [0.10185242, -0.005760193], [0.11180115, 0.0024871826], [0.12962341, 0.015071869], [0.14656067, 0.018680573]]
        }
    }
}
