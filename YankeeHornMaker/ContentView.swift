import SwiftUI

struct ContentView: View {
    @StateObject private var engine = HornEngine()
    @StateObject private var store = MelodyStore()

    var body: some View {
        TabView {
            PlayView(engine: engine)
                .tabItem { Label("鳴らす", systemImage: "speaker.wave.3.fill") }
            MakeView(engine: engine, store: store)
                .tabItem { Label("作る", systemImage: "square.grid.3x3.fill") }
        }
        .tint(Theme.gold)
    }
}

// MARK: - Play

struct PlayView: View {
    @ObservedObject var engine: HornEngine
    @State private var selected: UUID?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                titleBlock
                tonePanel
                presetGrid
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .safeAreaInset(edge: .bottom) {
            stopButton
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
        }
        .background(AppBackdrop())
    }

    private var titleBlock: some View {
        VStack(spacing: 6) {
            Text("YANKEE")
                .font(.system(size: 46, weight: .black, design: .rounded))
                .italic()
                .foregroundStyle(
                    LinearGradient(colors: [.white, Theme.gold, Theme.deepGold], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: Theme.red.opacity(0.86), radius: 2, x: 3, y: 3)
                .shadow(color: Theme.purple.opacity(0.65), radius: 12)

            Text("HORN MAKER")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 5)
                .background(Capsule().fill(Theme.ink))
                .overlay(Capsule().stroke(Theme.gold.opacity(0.75), lineWidth: 1))
        }
        .accessibilityElement(children: .combine)
    }

    private var tonePanel: some View {
        VStack(spacing: 12) {
            HStack {
                Label("音色", systemImage: "waveform")
                    .font(Theme.sectionFont)
                    .foregroundStyle(Theme.gold)
                Spacer()
                Toggle("", isOn: $engine.loop)
                    .labelsHidden()
                    .tint(Theme.red)
                Text("ループ")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.text)
            }

            Picker("音色", selection: $engine.tone) {
                ForEach(HornTone.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 8) {
                HStack {
                    Label("直結マフラー", systemImage: "flame.fill")
                        .font(Theme.bodyFont)
                        .foregroundStyle(engine.bikeSound == .off ? Theme.muted : Theme.red)
                    Spacer()
                }
                Picker("直結マフラー", selection: $engine.bikeSound) {
                    ForEach(BikeSound.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(14)
        .metalPanel(cornerRadius: 16)
    }

    private var presetGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(HornLibrary.presets) { preset in
                Button {
                    selected = preset.id
                    engine.play(notes: preset.notes, tempo: preset.tempo, tone: engine.tone, loop: engine.loop)
                } label: {
                    PresetCard(preset: preset, isSelected: selected == preset.id)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }

    private var stopButton: some View {
        Button {
            engine.stop()
        } label: {
            Label("止める", systemImage: "stop.fill")
        }
        .buttonStyle(BrushButtonStyle(kind: .red))
        .opacity(engine.isPlaying ? 1 : 0.55)
    }
}

private struct PresetCard: View {
    let preset: HornPreset
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(isSelected ? Color.black : Theme.gold)
                Spacer()
                Text("\(Int(preset.tempo))")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(isSelected ? Color.black.opacity(0.72) : Theme.muted)
            }

            Text(preset.name)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .foregroundStyle(isSelected ? Color.black : Theme.text)

            Text("BPM")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(isSelected ? Color.black.opacity(0.62) : Theme.red)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? Theme.red : Theme.gold.opacity(0.58), lineWidth: isSelected ? 2.6 : 1.2)
        )
        .shadow(color: isSelected ? Theme.red.opacity(0.38) : .black.opacity(0.38), radius: 10, x: 0, y: 6)
    }

    private var cardBackground: some ShapeStyle {
        if isSelected {
            return LinearGradient(colors: [Theme.gold, Color.white.opacity(0.86), Theme.deepGold], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: [Theme.panel.opacity(0.96), Color.black.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
