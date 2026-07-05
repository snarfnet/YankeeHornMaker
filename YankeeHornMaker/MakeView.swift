import SwiftUI

struct MakeView: View {
    @ObservedObject var engine: HornEngine
    @ObservedObject var store: MelodyStore

    private let stepCount = 16
    private let pitches = Array((60...72).reversed())
    @State private var steps: [Int] = [60, 64, 67, 72, 67, 64, 60, -1, 60, 64, 67, 72, 67, 64, 60, -1]
    @State private var tempo: Double = 180
    @State private var name = ""
    @State private var showSaved = false

    var body: some View {
        ZStack {
            AppBackdrop()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    header
                    grid
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 12)
            }
            .safeAreaInset(edge: .bottom) {
                controls
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)
            }
        }
        .sheet(isPresented: $showSaved) { savedSheet }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("MAKE YOUR")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.red)
                Text("族ホーン")
                    .font(.system(size: 31, weight: .black, design: .rounded))
                    .italic()
                    .foregroundStyle(
                        LinearGradient(colors: [.white, Theme.gold, Theme.deepGold], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: Theme.purple.opacity(0.7), radius: 8)
            }
            Spacer()
            Button {
                showSaved = true
            } label: {
                Image(systemName: "tray.full.fill")
            }
            .chromeIconButton()
            .accessibilityLabel("保存したメロディ")
        }
    }

    private var grid: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("ステップ盤", systemImage: "square.grid.3x3.fill")
                    .font(Theme.sectionFont)
                    .foregroundStyle(Theme.gold)
                Spacer()
                Text("16連")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.red)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 5) {
                    beatNumbers
                    ForEach(pitches, id: \.self) { pitch in
                        HStack(spacing: 5) {
                            Text(NoteName.label(pitch))
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(Theme.text.opacity(0.82))
                                .frame(width: 36, alignment: .trailing)
                            ForEach(0..<stepCount, id: \.self) { step in
                                stepCell(step: step, pitch: pitch)
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(14)
        .metalPanel(cornerRadius: 18)
    }

    private var beatNumbers: some View {
        HStack(spacing: 5) {
            Text("")
                .frame(width: 36)
            ForEach(0..<stepCount, id: \.self) { step in
                Text(step % 4 == 0 ? "\(step + 1)" : "・")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(step % 4 == 0 ? Theme.gold : Theme.muted.opacity(0.6))
                    .frame(width: 27, height: 14)
            }
        }
    }

    private func stepCell(step: Int, pitch: Int) -> some View {
        let on = steps[step] == pitch
        return Button {
            steps[step] = on ? -1 : pitch
        } label: {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: on ? [Theme.gold, .white, Theme.deepGold] : [Theme.panelHot, Color.black],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 27, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(on ? Theme.red : Theme.gold.opacity(0.20), lineWidth: on ? 1.3 : 0.8)
                )
                .shadow(color: on ? Theme.gold.opacity(0.42) : .clear, radius: 7)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(NoteName.label(pitch)) \(step + 1)")
    }

    private var controls: some View {
        VStack(spacing: 12) {
            Picker("音色", selection: $engine.tone) {
                ForEach(HornTone.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 8) {
                HStack {
                    Label("速さ", systemImage: "speedometer")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.text)
                    Spacer()
                    Text("\(Int(tempo)) BPM")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.gold)
                }
                Slider(value: $tempo, in: 80...260, step: 5)
                    .tint(Theme.gold)
            }

            HStack(spacing: 12) {
                Button {
                    engine.play(notes: steps, tempo: tempo, tone: engine.tone, loop: true)
                } label: {
                    Label("鳴らす", systemImage: "play.fill")
                }
                .buttonStyle(BrushButtonStyle(kind: .gold))

                Button {
                    engine.stop()
                } label: {
                    Label("止める", systemImage: "stop.fill")
                }
                .buttonStyle(BrushButtonStyle(kind: .red))
            }

            HStack(spacing: 10) {
                TextField("メロディ名", text: $name)
                    .font(Theme.bodyFont)
                    .textInputAutocapitalization(.characters)
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.black.opacity(0.58)))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Theme.gold.opacity(0.42), lineWidth: 1))
                    .foregroundStyle(Theme.text)

                Button {
                    let n = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "MY HORN" : name
                    store.add(SavedMelody(name: n, notes: steps, tempo: tempo, tone: engine.tone.rawValue))
                    name = ""
                } label: {
                    Image(systemName: "square.and.arrow.down.fill")
                }
                .chromeIconButton()
                .accessibilityLabel("保存")
            }
        }
        .padding(14)
        .metalPanel(cornerRadius: 18, isHot: true)
    }

    private var savedSheet: some View {
        NavigationView {
            List {
                if store.melodies.isEmpty {
                    Text("保存したメロディはまだありません")
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
            .navigationTitle("保存メロディ")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { showSaved = false }
                }
            }
        }
    }

    private func normalized(_ notes: [Int]) -> [Int] {
        var result = Array(notes.prefix(stepCount))
        while result.count < stepCount { result.append(-1) }
        return result
    }
}
