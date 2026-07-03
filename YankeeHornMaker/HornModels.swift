import Foundation

/// プリセットのホーンメロディ。-1 は休符。
struct HornPreset: Identifiable {
    let id = UUID()
    let name: String
    let notes: [Int]
    let tempo: Double
}

enum HornLibrary {
    // C4 = 60。すべてパブリックドメイン曲かオリジナルの並び。
    static let presets: [HornPreset] = [
        HornPreset(name: "パラリラ",
                   notes: [60, 64, 67, 72, 67, 64, 60, 64, 67, 72, 67, 64], tempo: 210),
        HornPreset(name: "パトカー",
                   notes: [69, 62, 69, 62, 69, 62, 69, 62], tempo: 130),
        HornPreset(name: "突撃ラッパ",
                   notes: [67, 72, 76, 79, -1, 76, 79, -1], tempo: 150),
        HornPreset(name: "きらきら星",
                   notes: [60, 60, 67, 67, 69, 69, 67, -1, 65, 65, 64, 64, 62, 62, 60, -1], tempo: 150),
        HornPreset(name: "蛍の光",
                   notes: [67, 72, 72, 72, 76, 74, 72, 74, 76, 72, 72, 76, 79], tempo: 120),
        HornPreset(name: "昇天スケール",
                   notes: [60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 77, 79], tempo: 220)
    ]
}

/// 自作したホーンメロディの保存単位。
struct SavedMelody: Codable, Identifiable {
    var id = UUID()
    var name: String
    var notes: [Int]
    var tempo: Double
    var tone: String
}

/// 自作メロディをUserDefaultsに永続化するストア。
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
        guard midi >= 0 else { return "—" }
        return names[((midi % 12) + 12) % 12]
    }
}
