import SwiftUI

struct MakeView: View {
    @ObservedObject var engine: HornEngine
    @ObservedObject var store: MelodyStore

    private let stepCount = 16
    private let pitches = Array((60...72).reversed()) // ド〜高ド、上が高音
    @State private var steps: [Int] = [60, 64, 67, 72, 67, 64, 60, -1, 60, 64, 67, 72, 67, 64, 60, -1]
    @State private var tempo: Double = 180
    @State private var name = ""
    @State private var showSaved = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 12) {
                header
                grid
                controls
            }
            .padding(.top, 8)
        }
        .sheet(isPresented: $showSaved) { savedSheet }
    }

    private var header: some View {
        HStack {
            Text("ホーンを作る")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(Theme.gold)
            Spacer()
            Button {
                showSaved = true
            } label: {
                Image(systemName: "tray.full.fill").foregroundStyle(Theme.gold)
            }
        }
        .padding(.horizontal)
    }

    private var grid: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 3) {
                ForEach(pitches, id: \.self) { pitch in
                    HStack(spacing: 3) {
                        Text(NoteName.label(pitch))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.text.opacity(0.7))
                            .frame(width: 34, alignment: .trailing)
                        ForEach(0..<stepCount, id: \.self) { step in
                            let on = steps[step] == pitch
                            Rectangle()
                                .fill(on ? Theme.gold : Theme.panel)
                                .frame(width: 26, height: 22)
                                .cornerRadius(4)
                                .onTapGesture {
                                    steps[step] = on ? -1 : pitch
                                }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            Picker("音色", selection: $engine.tone) {
                ForEach(HornTone.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            HStack {
                Text("速さ").foregroundStyle(Theme.text)
                Slider(value: $tempo, in: 80...260, step: 5).tint(Theme.gold)
                Text("\(Int(tempo))").foregroundStyle(Theme.text).frame(width: 40)
            }

            HStack(spacing: 12) {
                Button {
                    engine.play(notes: steps, tempo: tempo, tone: engine.tone, loop: true)
                } label: {
                    Label("再生", systemImage: "play.fill")
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.gold))
                        .foregroundStyle(.black)
                }
                Button {
                    engine.stop()
                } label: {
                    Label("停止", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.red))
                        .foregroundStyle(Theme.text)
                }
            }

            HStack(spacing: 12) {
                TextField("メロディ名", text: $name)
                    .textFieldStyle(.roundedBorder)
                Button("保存") {
                    let n = name.isEmpty ? "MY HORN" : name
                    store.add(SavedMelody(name: n, notes: steps, tempo: tempo, tone: engine.tone.rawValue))
                    name = ""
                }
                .fontWeight(.bold)
                .foregroundStyle(Theme.gold)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 6)
    }

    private var savedSheet: some View {
        NavigationView {
            List {
                if store.melodies.isEmpty {
                    Text("保存したホーンはまだありません")
                        .foregroundStyle(.secondary)
                }
                ForEach(store.melodies) { melody in
                    Button {
                        steps = normalized(melody.notes)
                        tempo = melody.tempo
                        engine.tone = HornTone(rawValue: melody.tone) ?? .bugle
                        showSaved = false
                    } label: {
                        HStack {
                            Text(melody.name).fontWeight(.bold)
                            Spacer()
                            Text("\(Int(melody.tempo)) BPM").foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { store.delete(at: $0) }
            }
            .navigationTitle("保存したホーン")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { showSaved = false }
                }
            }
        }
    }

    /// 保存データが別ステップ数でも編集グリッドに収まるよう整える。
    private func normalized(_ notes: [Int]) -> [Int] {
        var result = Array(notes.prefix(stepCount))
        while result.count < stepCount { result.append(-1) }
        return result
    }
}
