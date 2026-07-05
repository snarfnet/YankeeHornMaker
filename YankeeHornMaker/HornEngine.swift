import Foundation
import AVFoundation

enum HornTone: String, CaseIterable, Codable, Identifiable {
    case bugle = "リアルホーン"
    case shrill = "甲高いホーン"
    case horn = "重低音ホーン"
    case electronic = "電子ホーン"

    var id: String { rawValue }

    var sampleInfo: (resource: String, f0: Double)? {
        switch self {
        case .bugle: return ("BugleNote", 464.2)
        // 同じラッパ音源を基準ピッチ半分で鳴らし、1オクターブ上の甲高い音色にする
        case .shrill: return ("BugleNote", 232.1)
        case .horn: return ("HornNote", 308.4)
        case .electronic: return nil
        }
    }
}

/// 背景で流すバイクの排気音。OFF・空ぶかし・走行から選ぶ。
enum BikeSound: String, CaseIterable, Identifiable {
    case off = "OFF"
    case idle = "空ぶかし"
    case running = "走行"

    var id: String { rawValue }

    var resource: String? {
        switch self {
        case .off: return nil
        case .idle: return "BikeExhaust"
        case .running: return "BikeRun"
        }
    }
}

/// メロディを書き出すファイル形式。MP3は非対応（iOS標準でエンコード不可）。
enum ExportFormat: String, CaseIterable, Identifiable {
    case aiff = "AIFF"
    case m4a = "M4A"

    var id: String { rawValue }
    var ext: String { self == .aiff ? "aiff" : "m4a" }
}

/// Renders short horn melodies into one audio buffer and plays them.
final class HornEngine: ObservableObject {
    @Published var isPlaying = false
    @Published var tone: HornTone = .bugle
    @Published var tempo: Double = 160
    @Published var loop = false
    @Published var bikeSound: BikeSound = .off { didSet { applyBikeSound() } }

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let livePlayer = AVAudioPlayerNode()
    private let voiceMixer = AVAudioMixerNode()
    private let reverb = AVAudioUnitReverb()
    private let bikePlayer = AVAudioPlayerNode()
    private var bikeBuffers: [BikeSound: AVAudioPCMBuffer] = [:]
    private let sampleRate: Double = 44100
    private var configured = false

    private var samples: [HornTone: [Float]] = [:]

    init() {
        for tone in HornTone.allCases {
            if let info = tone.sampleInfo, let data = Self.loadSample(info.resource) {
                samples[tone] = data
            }
        }
    }

    private static func loadSample(_ resource: String) -> [Float]? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url) else { return nil }
        let frames = AVAudioFrameCount(file.length)
        guard frames > 0,
              let buf = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frames),
              (try? file.read(into: buf)) != nil,
              let ch = buf.floatChannelData else { return nil }
        return Array(UnsafeBufferPointer(start: ch[0], count: Int(buf.frameLength)))
    }

    private func configure() {
        guard !configured else { return }
        configured = true
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        engine.attach(player)
        engine.attach(livePlayer)
        engine.attach(voiceMixer)
        engine.attach(reverb)
        // 族のトンネルサウンドっぽく大きめの残響を薄めにかける
        reverb.loadFactoryPreset(.largeHall)
        reverb.wetDryMix = 28
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        // メロディ再生とMIDIライブ演奏をミキサーでまとめてから残響へ。
        // reverbはエフェクトで入力が1つだけなので、2つの再生ノードを直結すると落ちる。
        engine.connect(player, to: voiceMixer, format: format)
        engine.connect(livePlayer, to: voiceMixer, format: format)
        engine.connect(voiceMixer, to: reverb, format: format)
        engine.connect(reverb, to: engine.mainMixerNode, format: format)
        // 直結マフラーの排気音（背景ループ、残響は通さず生音で）
        engine.attach(bikePlayer)
        var bikeFormat: AVAudioFormat?
        for kind in BikeSound.allCases {
            guard let res = kind.resource,
                  let url = Bundle.main.url(forResource: res, withExtension: "wav"),
                  let file = try? AVAudioFile(forReading: url),
                  let buf = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)),
                  (try? file.read(into: buf)) != nil else { continue }
            bikeBuffers[kind] = buf
            bikeFormat = file.processingFormat
        }
        if let format = bikeFormat {
            engine.connect(bikePlayer, to: engine.mainMixerNode, format: format)
        }
        engine.prepare()
        try? engine.start()
    }

    private func applyBikeSound() {
        configure()
        bikePlayer.stop()
        guard let buf = bikeBuffers[bikeSound] else { return }
        bikePlayer.scheduleBuffer(buf, at: nil, options: .loops, completionHandler: nil)
        bikePlayer.play()
    }

    func stop() {
        player.stop()
        isPlaying = false
    }

    func play(notes: [Int], tempo: Double, tone: HornTone, loop: Bool) {
        configure()
        player.stop()
        self.tempo = tempo
        self.tone = tone
        self.loop = loop
        guard let buffer = renderBuffer(notes: notes, tempo: tempo, tone: tone) else { return }
        isPlaying = true
        if loop {
            player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        } else {
            player.scheduleBuffer(buffer, at: nil, options: []) { [weak self] in
                DispatchQueue.main.async { self?.isPlaying = false }
            }
        }
        player.play()
    }

    /// MIDIキーで押した1音を、いまの音色で即座に鳴らす。新しい音が前の音を切る（モノフォニック）。
    func playLive(_ midi: Int) {
        guard midi >= 0 else { return }
        configure()
        guard let buffer = renderBuffer(notes: [midi], tempo: 60, tone: tone) else { return }
        livePlayer.stop()
        livePlayer.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        livePlayer.play()
    }

    /// メロディをAIFF/M4Aで書き出し、共有用の一時ファイルURLを返す。
    func export(notes: [Int], tempo: Double, tone: HornTone, name: String, format: ExportFormat) -> URL? {
        guard let buffer = renderBuffer(notes: notes, tempo: tempo, tone: tone) else { return nil }
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "-")
        let base = cleaned.isEmpty ? "YankeeHorn" : cleaned
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(base).\(format.ext)")
        try? FileManager.default.removeItem(at: url)

        let settings: [String: Any]
        switch format {
        case .aiff:
            settings = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: sampleRate,
                AVNumberOfChannelsKey: 2,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: true
            ]
        case .m4a:
            settings = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: sampleRate,
                AVNumberOfChannelsKey: 2,
                AVEncoderBitRateKey: 128_000
            ]
        }
        do {
            let file = try AVAudioFile(forWriting: url, settings: settings)
            try file.write(from: buffer)
            return url
        } catch {
            return nil
        }
    }

    private func renderBuffer(notes: [Int], tempo: Double, tone: HornTone) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let secondsPerStep = 60.0 / max(tempo, 30) / 2.0
        let framesPerStep = Int(secondsPerStep * sampleRate)
        let totalFrames = framesPerStep * max(notes.count, 1)
        guard totalFrames > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalFrames)) else { return nil }
        buffer.frameLength = AVAudioFrameCount(totalFrames)
        let left = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        for i in 0..<totalFrames {
            left[i] = 0
            right[i] = 0
        }

        let gate = 0.85
        let noteFrames = Int(Double(framesPerStep) * gate)
        let sample = samples[tone]
        for (idx, note) in notes.enumerated() where note >= 0 {
            let freq = 440.0 * pow(2.0, (Double(note) - 69.0) / 12.0)
            let start = idx * framesPerStep
            if let sample = sample, let info = tone.sampleInfo, !sample.isEmpty {
                renderSample(freq: freq, sample: sample, sampleF0: info.f0,
                             left: left, right: right,
                             start: start, length: noteFrames, total: totalFrames)
            } else {
                renderNote(freq: freq, left: left, right: right,
                           start: start, length: noteFrames, total: totalFrames)
            }
        }
        return buffer
    }

    private func renderSample(freq: Double, sample: [Float], sampleF0: Double,
                              left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>,
                              start: Int, length: Int, total: Int) {
        let ratio = freq / sampleF0
        let attack = Int(0.005 * sampleRate)
        let release = Int(0.02 * sampleRate)
        let sampleCount = sample.count
        let detune = pow(2.0, 8.0 / 1200.0)
        let gain: Float = 0.9

        func sampleAt(_ pos: Double) -> Float? {
            let i = Int(pos)
            if i < 0 || i + 1 >= sampleCount { return nil }
            let frac = Float(pos - Double(i))
            return sample[i] * (1 - frac) + sample[i + 1] * frac
        }

        for n in 0..<length {
            let gi = start + n
            if gi >= total { break }

            var env: Float = 1.0
            if n < attack { env = Float(n) / Float(attack) }
            let relStart = length - release
            if n > relStart { env = min(env, max(0, Float(length - n) / Float(release))) }

            let g = env * gain
            let posL = Double(n) * ratio
            let posR = Double(n) * ratio / detune
            if let sl = sampleAt(posL) { left[gi] += sl * g }
            if let sr = sampleAt(posR) { right[gi] += sr * g }
        }
    }

    private func renderNote(freq: Double, left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>,
                            start: Int, length: Int, total: Int) {
        let harmonics = [1.0, 0.12, 0.55, 0.08, 0.35, 0.06, 0.24, 0.04, 0.17, 0.03]
        let detune = pow(2.0, 3.0 / 1200.0)
        let freqL = freq
        let freqR = freq * detune
        let attack = 0.008 * sampleRate
        let release = 0.05 * sampleRate
        let vibratoRate = 5.5
        let vibratoDepth = 0.002
        let nyquist = sampleRate / 2
        let gain: Float = 0.16

        for n in 0..<length {
            let gi = start + n
            if gi >= total { break }
            let t = Double(n) / sampleRate

            var env = 1.0
            if Double(n) < attack { env = Double(n) / attack }
            let relStart = Double(length) - release
            if Double(n) > relStart { env = min(env, max(0, (Double(length) - Double(n)) / release)) }

            let vib = 1.0 + vibratoDepth * sin(2 * .pi * vibratoRate * t)
            var sl = 0.0
            var sr = 0.0
            for (k, amp) in harmonics.enumerated() {
                let h = Double(k + 1)
                let fl = freqL * h * vib
                let fr = freqR * h * vib
                if fl < nyquist { sl += amp * sin(2 * .pi * fl * t) }
                if fr < nyquist { sr += amp * sin(2 * .pi * fr * t) }
            }
            let g = Float(env) * gain
            left[gi] += Float(sl) * g
            right[gi] += Float(sr) * g
        }
    }

    deinit {
        player.stop()
        livePlayer.stop()
        bikePlayer.stop()
        engine.stop()
    }
}
