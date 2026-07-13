import SwiftUI

struct ExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct MakeView: View {
    @ObservedObject var engine: HornEngine
    @ObservedObject var store: MelodyStore
    @ObservedObject var midi: MIDIManager

    private let stepCount = 16
    private let pitches = Array((60...72).reversed())
    @State private var steps: [Int] = [60, 64, 67, 72, 67, 64, 60, -1, 60, 64, 67, 72, 67, 64, 60, -1]
    @State private var tempo: Double = 180
    @State private var name = ""
    @State private var showSaved = false
    @State private var exportItem: ExportItem?
    @State private var midiInput = false
    @State private var cursor = 0
    @State private var previousSteps: [Int]?
    @State private var savedMessage: String?

    var body: some View {
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
        .background(AppBackdrop())
        .sheet(isPresented: $showSaved) { savedSheet }
        .sheet(item: $exportItem) { ShareSheet(items: [$0.url]) }
        .overlay(alignment: .top) {
            if let savedMessage {
                Label(savedMessage, systemImage: "checkmark.circle.fill")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(Capsule().fill(Theme.gold))
                    .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onChange(of: midi.noteCount) { _ in
            guard midiInput else { return }
            inputMIDINote(midi.lastNote)
        }
        .onChange(of: midiInput) { on in
            if on { cursor = 0 }
        }
        // 再生中にステップ盤・速さ・音色を触ったら、止めずにその場で反映する。
        .onChange(of: steps) { newSteps in
            engine.updateLoop(notes: newSteps, tempo: tempo, tone: engine.tone)
        }
        .onChange(of: tempo) { newTempo in
            engine.updateLoop(notes: steps, tempo: newTempo, tone: engine.tone)
        }
        .onChange(of: engine.tone) { newTone in
            engine.updateLoop(notes: steps, tempo: tempo, tone: newTone)
        }
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

            HStack(spacing: 8) {
                Button {
                    guard let previousSteps else { return }
                    let current = steps
                    steps = previousSteps
                    self.previousSteps = current
                } label: {
                    Label("戻す", systemImage: "arrow.uturn.backward")
                }
                .disabled(previousSteps == nil)

                Button(role: .destructive) {
                    rememberSteps()
                    steps = Array(repeating: -1, count: stepCount)
                } label: {
                    Label("全消去", systemImage: "trash")
                }

                Spacer()
                Text("マスをタップして音を置く")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.muted)
            }
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .buttonStyle(.borderless)

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
            rememberSteps()
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
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(Theme.purple, lineWidth: 2)
                        .opacity(midiInput && step == cursor ? 1 : 0)
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

            HStack(spacing: 10) {
                Label("荒さ", systemImage: "bolt.fill")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.text)
                Slider(value: $engine.grit, in: 0...1)
                    .tint(Theme.red)
                Text("\(Int(engine.grit * 100))")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundStyle(Theme.gold)
                    .frame(width: 28, alignment: .trailing)
            }

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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        savedMessage = "「\(n)」を保存しました"
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { savedMessage = nil }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down.fill")
                }
                .chromeIconButton()
                .accessibilityLabel("保存")
            }

            HStack(spacing: 10) {
                Label("書き出し", systemImage: "square.and.arrow.up.fill")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.text)
                Spacer()
                ForEach(ExportFormat.allCases) { format in
                    Button(format.rawValue) {
                        export(format)
                    }
                    .buttonStyle(BrushButtonStyle(kind: .dark))
                    .frame(width: 88)
                }
            }

            HStack(spacing: 10) {
                Label("MIDI入力", systemImage: "pianokeys")
                    .font(Theme.bodyFont)
                    .foregroundStyle(midi.isConnected ? Theme.gold : Theme.muted)
                Text(midi.isConnected ? "接続中" : "未接続")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(midi.isConnected ? Theme.red : Theme.muted)
                Spacer()
                Text("打ち込み")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.text)
                Toggle("", isOn: $midiInput)
                    .labelsHidden()
                    .tint(Theme.red)
            }
        }
        .padding(14)
        .metalPanel(cornerRadius: 18, isHot: true)
    }

    private func export(_ format: ExportFormat) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "YankeeHorn" : name
        if let url = engine.export(notes: steps, tempo: tempo, tone: engine.tone, name: n, format: format) {
            exportItem = ExportItem(url: url)
        }
    }

    /// MIDIで受けた音をステップ盤に打ち込む。表示範囲(60...72)へオクターブ移調してカーソルを進める。
    private func inputMIDINote(_ note: Int) {
        guard note >= 0 else { return }
        var n = note
        while n < 60 { n += 12 }
        while n > 72 { n -= 12 }
        rememberSteps()
        steps[cursor] = n
        cursor = (cursor + 1) % stepCount
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
                        rememberSteps()
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

    private func rememberSteps() {
        previousSteps = steps
    }
}
