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

// MARK: - 鳴らす

struct PlayView: View {
    @ObservedObject var engine: HornEngine
    @State private var selected: UUID?

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 18) {
                Text("YANKEE HORN")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.gold)
                    .shadow(color: Theme.red.opacity(0.6), radius: 8)
                    .padding(.top, 8)

                Picker("音色", selection: $engine.tone) {
                    ForEach(HornTone.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Toggle(isOn: $engine.loop) {
                    Text("リピート").foregroundStyle(Theme.text)
                }
                .tint(Theme.red)
                .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(HornLibrary.presets) { preset in
                            Button {
                                selected = preset.id
                                engine.play(notes: preset.notes, tempo: preset.tempo,
                                            tone: engine.tone, loop: engine.loop)
                            } label: {
                                Text(preset.name)
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundStyle(Theme.text)
                                    .frame(maxWidth: .infinity, minHeight: 80)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Theme.panel)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(selected == preset.id ? Theme.gold : Theme.red.opacity(0.4),
                                                            lineWidth: selected == preset.id ? 3 : 1.5)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Button {
                    engine.stop()
                } label: {
                    Label("止める", systemImage: "stop.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Theme.text)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.red))
                }
                .padding(.horizontal)
                .padding(.bottom, 6)
                .opacity(engine.isPlaying ? 1 : 0.4)
            }
        }
    }
}
