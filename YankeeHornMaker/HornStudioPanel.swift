import SwiftUI

struct HornStudioPanel: View {
    @ObservedObject var engine: HornEngine
    var body: some View {
        DisclosureGroup("ホーン・スタジオ") {
            VStack(spacing: 12) {
                slider("スウィング", value: $engine.studio.swing, range: 0...0.5)
                slider("音の長さ", value: $engine.studio.gate, range: 0.15...0.98)
                slider("ステレオエコー", value: $engine.studio.echo, range: 0...0.6)
                Stepper("移調：\(engine.studio.transpose) 半音", value: $engine.studio.transpose, in: -24...24)
                Picker("二重奏", selection: $engine.studio.harmony) {
                    Text("単音").tag(0); Text("長3度").tag(4); Text("5度").tag(7); Text("オクターブ").tag(12)
                }.pickerStyle(.menu)
                Text("変更は予約済みのループ再生後に反映します。書き出しにはエコーを含み、背景のバイク音と再生時の残響は含みません。")
                    .font(.caption).foregroundStyle(Theme.muted)
                Button("スタジオ設定を初期値に戻す") { engine.studio = HornStudioSettings() }
            }.padding(.top, 10)
        }.font(Theme.bodyFont).foregroundStyle(Theme.text).tint(Theme.gold)
    }
    private func slider(_ title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(title)：\(Int(value.wrappedValue * 100))%")
            Slider(value: value, in: range)
        }
    }
}
