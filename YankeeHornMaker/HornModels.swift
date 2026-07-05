import Foundation

/// Preset horn melodies. `-1` means rest.
struct HornPreset: Identifiable {
    let id = UUID()
    let name: String
    let notes: [Int]
    let tempo: Double
}

enum HornLibrary {
    // C4 = 60. パブリックドメイン曲（童謡・クラシック・伝統曲）とオリジナルの族フレーズ。
    static let presets: [HornPreset] = [
        // --- 族の定番・オリジナル ---
        HornPreset(name: "パラリラ",
                   notes: [60, 64, 67, 72, 67, 64, 60, 64, 67, 72, 67, 64], tempo: 210),
        HornPreset(name: "パトカー",
                   notes: [69, 62, 69, 62, 69, 62, 69, 62], tempo: 130),
        HornPreset(name: "爆走ラッパ",
                   notes: [67, 72, 76, 79, -1, 76, 79, -1], tempo: 150),
        HornPreset(name: "夜の帝王",
                   notes: [67, 72, 72, 72, 76, 74, 72, 74, 76, 72, 72, 76, 79], tempo: 120),
        HornPreset(name: "昇天スケール",
                   notes: [60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 77, 79], tempo: 220),
        HornPreset(name: "特攻天使",
                   notes: [72, 71, 72, 74, 72, 71, 69, -1, 69, 71, 72, 71, 69, 67], tempo: 170),
        HornPreset(name: "夜露死苦",
                   notes: [60, 63, 65, 66, 67, -1, 67, 66, 65, 63, 60, -1], tempo: 140),
        HornPreset(name: "直線番長",
                   notes: [67, 67, 74, 74, 72, 71, 72, -1, 67, 67, 74, 79], tempo: 200),
        HornPreset(name: "完全燃焼",
                   notes: [60, 64, 67, 72, 76, 79, 84, -1, 84, 79, 76, 72], tempo: 210),
        HornPreset(name: "単車小僧",
                   notes: [69, 69, 72, 69, 67, 69, -1, 67, 67, 69, 67, 65], tempo: 160),
        HornPreset(name: "雷鳴",
                   notes: [55, 55, 62, 62, 60, 62, 55, -1, 62, 60, 59, 60], tempo: 130),
        HornPreset(name: "疾風",
                   notes: [76, 74, 72, 71, 69, 67, 65, 64, 62, 60, -1, -1], tempo: 230),
        HornPreset(name: "天下無敵",
                   notes: [67, 72, 67, 72, 76, 72, 76, 79, -1, 79, 76, 72], tempo: 180),
        HornPreset(name: "爆音マーチ",
                   notes: [60, 60, 67, 67, 72, 67, 60, -1, 64, 64, 71, 67], tempo: 190),
        // --- 童謡・唱歌 ---
        HornPreset(name: "キラキラ星",
                   notes: [60, 60, 67, 67, 69, 69, 67, -1, 65, 65, 64, 64, 62, 62, 60, -1], tempo: 150),
        HornPreset(name: "メリーの羊",
                   notes: [64, 62, 60, 62, 64, 64, 64, -1, 62, 62, 62, -1, 64, 67, 67], tempo: 150),
        HornPreset(name: "ロンドン橋",
                   notes: [67, 69, 67, 65, 64, 65, 67, -1, 62, 64, 65, -1, 64, 65, 67], tempo: 150),
        HornPreset(name: "かえるの輪唱",
                   notes: [60, 62, 64, 65, 64, 62, 60, -1, 64, 65, 67, 69, 67, 65, 64], tempo: 160),
        HornPreset(name: "ジングルベル",
                   notes: [64, 64, 64, -1, 64, 64, 64, -1, 64, 67, 60, 62, 64], tempo: 180),
        HornPreset(name: "聖者の行進",
                   notes: [60, 64, 65, 67, -1, 60, 64, 65, 67, -1, 64, 60, 64, 62], tempo: 160),
        // --- 伝統・和 ---
        HornPreset(name: "さくらさくら",
                   notes: [69, 69, 71, -1, 69, 69, 71, -1, 69, 71, 74, 71, 69, 71, 69, 65], tempo: 100),
        HornPreset(name: "君が代",
                   notes: [62, 64, 65, 64, 62, 64, 67, 65, 64, 62, -1, 60, 62, 64], tempo: 90),
        HornPreset(name: "ソーラン節",
                   notes: [69, 69, 67, 69, 72, 69, 67, 64, -1, 64, 67, 69, 67], tempo: 130),
        HornPreset(name: "蛍の光",
                   notes: [60, 65, 65, 69, 67, 65, 69, 67, 65, 60, 60, 65, 72], tempo: 110),
        // --- クラシック ---
        HornPreset(name: "歓喜の歌",
                   notes: [64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62], tempo: 140),
        HornPreset(name: "エリーゼのために",
                   notes: [76, 75, 76, 75, 76, 71, 74, 72, 69, -1, 60, 64, 69, 71], tempo: 150),
        HornPreset(name: "運命",
                   notes: [67, 67, 67, 63, -1, 65, 65, 65, 62, -1, -1, -1], tempo: 130),
        HornPreset(name: "ウィリアム・テル",
                   notes: [64, 64, 64, 64, 64, 64, -1, 64, 64, 64, 67, 67, 64, 62], tempo: 230),
        HornPreset(name: "トルコ行進曲",
                   notes: [71, 69, 68, 69, 72, -1, 74, 72, 71, 72, 76, -1, 79, 76], tempo: 200),
        HornPreset(name: "アイネクライネ",
                   notes: [67, 62, 67, 62, 67, 62, 67, 71, 74, -1, 74, 79, 74, 79], tempo: 200),
        HornPreset(name: "美しく青きドナウ",
                   notes: [62, 64, 67, -1, 71, -1, 71, -1, 74, -1, 74, -1], tempo: 180),
        HornPreset(name: "朝",
                   notes: [67, 64, 62, 60, 62, 64, 67, 64, 62, 60, 62, 64], tempo: 140),
        HornPreset(name: "山の魔王",
                   notes: [60, 62, 63, 65, 67, 63, 67, -1, 62, 65, 71, 67], tempo: 160),
        HornPreset(name: "闘牛士",
                   notes: [60, 67, 67, -1, 69, 69, 71, 71, 72, -1, 72, 71, 69, 67], tempo: 150),
        HornPreset(name: "カンカン",
                   notes: [60, 67, 60, 67, -1, 60, 62, 64, 65, 67, -1, 72], tempo: 240),
        HornPreset(name: "ハバネラ",
                   notes: [74, 73, 72, 71, 70, 69, 68, 67, -1, 67, 68, 69], tempo: 120),
        HornPreset(name: "威風堂々",
                   notes: [71, 69, 67, 69, 74, -1, 72, 71, 69, 67, 65, 67], tempo: 100),
        HornPreset(name: "ラ・マルセイエーズ",
                   notes: [62, 62, 62, 67, 67, 69, 69, 74, -1, 72, 71, 69], tempo: 130),
        HornPreset(name: "ハンガリー舞曲",
                   notes: [69, 72, 71, 69, 67, 69, 71, 72, 74, 72, 71, 69], tempo: 150),
        // --- 世界の民謡・行進曲 ---
        HornPreset(name: "ヤンキードゥードゥル",
                   notes: [60, 60, 62, 64, 60, 64, 62, -1, 60, 60, 62, 64, 60, -1, 59], tempo: 180),
        HornPreset(name: "オー・スザンナ",
                   notes: [60, 62, 64, 67, 67, 69, 67, 64, 60, 62, 64, 64, 62, 60], tempo: 170),
        HornPreset(name: "草競馬",
                   notes: [67, 67, 64, 67, 69, 67, 64, -1, 64, 62, 64, 62, 60], tempo: 180),
        HornPreset(name: "ラ・クカラチャ",
                   notes: [60, 60, 60, 65, 69, -1, 60, 60, 60, 65, 69, -1], tempo: 180),
        HornPreset(name: "ハットダンス",
                   notes: [60, 64, 67, 64, 60, -1, 67, 60, 64, 67, -1, 72], tempo: 200),
        HornPreset(name: "グリーンスリーブス",
                   notes: [69, 72, 74, 76, 77, 76, 74, 71, 67, 69, 71, 72, 69], tempo: 130),
        HornPreset(name: "アメイジング",
                   notes: [67, 72, 76, 72, 76, 74, 72, 69, 67, -1, 67, 72], tempo: 110),
        HornPreset(name: "ダニーボーイ",
                   notes: [60, 65, 69, 67, 65, 69, 72, 76, 74, 72, 69, 65], tempo: 100),
        // --- ラッパ信号 ---
        HornPreset(name: "起床ラッパ",
                   notes: [60, 67, 64, 60, 67, 64, 60, -1, 67, 64, 60, 67], tempo: 200),
        HornPreset(name: "突撃ラッパ",
                   notes: [60, 60, 64, 67, 60, 64, 67, 72, -1, 72, 67, 64], tempo: 210),
        HornPreset(name: "消灯ラッパ",
                   notes: [67, 67, 72, -1, 67, 72, 76, -1, 67, 72, 76, 72], tempo: 90),
        // --- 童謡・唱歌 その2 ---
        HornPreset(name: "ちょうちょう",
                   notes: [67, 64, 64, 65, 62, 62, -1, 60, 62, 64, 65, 67, 67, 67], tempo: 140),
        HornPreset(name: "ぶんぶんぶん",
                   notes: [67, 64, 60, 65, 62, -1, 60, 62, 64, 65, 67, -1], tempo: 160),
        HornPreset(name: "うさぎとかめ",
                   notes: [67, 67, 64, 64, 65, 65, 62, -1, 60, 60, 62, 64, 65, 65, 64], tempo: 140),
        HornPreset(name: "大きな古時計",
                   notes: [69, 69, 69, 69, 72, 72, -1, 71, 69, 71, 72, 69, -1, 69], tempo: 100),
        HornPreset(name: "森のくまさん",
                   notes: [60, 64, 67, 64, 60, -1, 62, 65, 69, 65, 62, -1], tempo: 150),
        HornPreset(name: "峠の我が家",
                   notes: [60, 65, 65, 67, 69, 69, 69, -1, 67, 65, 67, 69, 65], tempo: 110),
        HornPreset(name: "線路は続くよ",
                   notes: [60, 65, 65, 65, 69, 67, 65, -1, 64, 65, 67, 65], tempo: 160),
        HornPreset(name: "ふるさと",
                   notes: [60, 60, 62, 64, 64, 62, 64, 67, 67, 69, 67, 64], tempo: 110),
        HornPreset(name: "春が来た",
                   notes: [67, 67, 69, 67, 64, 67, 69, -1, 67, 69, 72, 69, 67], tempo: 130),
        HornPreset(name: "ふじの山",
                   notes: [60, 62, 64, 60, 62, 64, 65, 67, -1, 67, 65, 64, 62, 60], tempo: 120),
        HornPreset(name: "春の小川",
                   notes: [67, 69, 67, 64, 67, 69, -1, 67, 64, 62, 60, 62, 64], tempo: 140),
        HornPreset(name: "汽車",
                   notes: [67, 67, 64, 62, 60, 62, 64, -1, 67, 67, 69, 67, 64], tempo: 150),
        // --- クラシック その2 ---
        HornPreset(name: "カノン",
                   notes: [76, 74, 72, 71, 69, 67, 69, 71, 72, 74, 72, 71], tempo: 100),
        HornPreset(name: "G線上のアリア",
                   notes: [62, 74, 71, 69, 67, 66, 67, 69, -1, 62, 74, 79], tempo: 80),
        HornPreset(name: "主よ人の望みの喜びよ",
                   notes: [67, 69, 71, 74, 72, 71, 72, 76, 74, 72, 71, 69], tempo: 120),
        HornPreset(name: "子犬のワルツ",
                   notes: [72, 71, 72, 71, 72, 71, 72, 76, 74, 72, -1, 72], tempo: 200),
        HornPreset(name: "別れの曲",
                   notes: [64, 65, 67, 67, 65, 64, -1, 64, 67, 71, 72, 71, 67], tempo: 100),
        HornPreset(name: "月光",
                   notes: [56, 60, 63, 56, 60, 63, 55, 59, 62, 55, 59, 62], tempo: 100),
        HornPreset(name: "家路",
                   notes: [64, 67, 67, -1, 64, 67, 69, 67, -1, 64, 62, 60, 62, 64, 64], tempo: 90),
        HornPreset(name: "花のワルツ",
                   notes: [72, 76, 79, -1, 77, 76, 74, 72, -1, 72, 74, 76, 74], tempo: 150),
        HornPreset(name: "白鳥",
                   notes: [72, 74, 76, 77, 79, 77, 76, 74, 72, -1, 71, 69], tempo: 90),
        HornPreset(name: "月の光",
                   notes: [65, 69, 72, 65, 69, 72, 74, 72, 69, 65, -1, 62], tempo: 90),
        HornPreset(name: "軍隊行進曲",
                   notes: [62, 62, -1, 67, 67, 67, 69, 71, -1, 71, 74, 71, 67], tempo: 140),
        HornPreset(name: "アヴェ・マリア",
                   notes: [67, 67, 69, 67, 67, 64, 60, -1, 60, 62, 64, 65, 67], tempo: 90),
        HornPreset(name: "野ばら",
                   notes: [67, 67, 69, 71, 71, 69, -1, 67, 71, 69, 69, 67], tempo: 120),
        HornPreset(name: "愛の挨拶",
                   notes: [72, 71, 72, 74, 72, 71, 69, -1, 67, 69, 71, -1], tempo: 110),
        HornPreset(name: "ジュピター",
                   notes: [71, 69, 67, 62, 64, 67, 65, -1, 64, 62, 64, 62, 60], tempo: 100),
        HornPreset(name: "ハレルヤ",
                   notes: [72, 72, 72, 72, 74, 72, -1, 72, 71, 69, -1, 67], tempo: 130),
        HornPreset(name: "トロイメライ",
                   notes: [60, 65, 69, 72, -1, 71, 69, 65, -1, 64, 65, 69], tempo: 90),
        HornPreset(name: "乙女の祈り",
                   notes: [72, 71, 72, 76, 74, 72, 71, 69, 71, 72, -1, 67], tempo: 120),
        HornPreset(name: "愛の夢",
                   notes: [65, 69, 72, 65, 69, 72, 76, 74, 72, 69, -1, 65], tempo: 100),
        HornPreset(name: "婚礼の合唱",
                   notes: [62, 62, 65, 67, 67, -1, 62, 65, 67, 71, 69, 67], tempo: 110),
        HornPreset(name: "ワルキューレの騎行",
                   notes: [62, 66, 69, -1, 62, 66, 69, 74, -1, 69, 71, 74], tempo: 130),
        HornPreset(name: "ラデツキー行進曲",
                   notes: [67, 67, 67, -1, 67, 72, -1, 67, 65, 64, 65, 67], tempo: 130),
        HornPreset(name: "天国と地獄",
                   notes: [64, 65, 67, 65, 64, 62, 60, 62, 64, 65, 67, -1], tempo: 240),
        // --- 世界の民謡 その2 ---
        HornPreset(name: "サンタ・ルチア",
                   notes: [60, 64, 64, -1, 64, 65, 64, 62, 60, -1, 62, 64, 67, 72], tempo: 110),
        HornPreset(name: "フニクリ・フニクラ",
                   notes: [60, 60, 65, 65, 69, -1, 69, 72, -1, 72, 69, 65, 60], tempo: 160),
        HornPreset(name: "帰れソレントへ",
                   notes: [69, 69, 71, 69, 67, 65, 64, -1, 62, 64, 67, 65], tempo: 100),
        HornPreset(name: "オー・ソレ・ミオ",
                   notes: [65, 67, 65, 64, 65, 69, -1, 72, 71, 69, 67, -1], tempo: 100),
        HornPreset(name: "コンドルは飛んでいく",
                   notes: [69, 69, 72, 71, 69, 67, -1, 64, 67, 69, 67, 64], tempo: 120),
        HornPreset(name: "埴生の宿",
                   notes: [60, 60, 62, 60, 65, 64, -1, 60, 60, 62, 60, 67, 65], tempo: 100),
        HornPreset(name: "アニーローリー",
                   notes: [60, 60, 60, 64, 62, 60, 62, 64, -1, 65, 64, 62], tempo: 100),
        HornPreset(name: "リパブリック讃歌",
                   notes: [60, 60, 60, 60, 60, 65, 64, 60, 64, -1, 67, 67], tempo: 150),
        HornPreset(name: "麦畑",
                   notes: [65, 67, 69, 69, -1, 69, 69, 72, 71, 69, 67, -1], tempo: 130),
        HornPreset(name: "スカボローフェア",
                   notes: [69, 69, 76, 76, 74, 72, 71, 69, 71, 72, 69, -1], tempo: 100),
        HornPreset(name: "クラリネットこわしちゃった",
                   notes: [60, 60, 60, 64, -1, 60, 64, -1, 60, 64, 67, 67, 65, 64, 62], tempo: 150),
        HornPreset(name: "ロッホ・ローモンド",
                   notes: [60, 62, 64, 65, 67, 69, 67, 65, -1, 64, 62, 60], tempo: 110),
        HornPreset(name: "おおブレネリ",
                   notes: [67, 60, 64, 67, -1, 60, 64, 67, 72, -1, 71, 69, 67], tempo: 140),
        HornPreset(name: "リンゴの木の下で",
                   notes: [60, 64, 67, 72, -1, 71, 69, 67, 69, 67, 65, 64], tempo: 120),
        HornPreset(name: "アビニョンの橋で",
                   notes: [65, 65, 64, 65, 67, -1, 65, 64, 62, 62, -1, 60], tempo: 150)
    ]
}

/// User-saved horn melody.
struct SavedMelody: Codable, Identifiable {
    var id = UUID()
    var name: String
    var notes: [Int]
    var tempo: Double
    var tone: String
}

/// Tiny persistence store for user melodies.
final class MelodyStore: ObservableObject {
    @Published private(set) var melodies: [SavedMelody] = []
    private let key = "saved_melodies"

    init() { load() }

    func add(_ melody: SavedMelody) {
        melodies.insert(melody, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        melodies.remove(atOffsets: offsets)
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SavedMelody].self, from: data) else { return }
        melodies = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(melodies) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

enum NoteName {
    private static let names = ["ド", "ド#", "レ", "レ#", "ミ", "ファ", "ファ#", "ソ", "ソ#", "ラ", "ラ#", "シ"]

    static func label(_ midi: Int) -> String {
        guard midi >= 0 else { return "-" }
        return names[((midi % 12) + 12) % 12]
    }
}
