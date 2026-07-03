import Foundation
import AVFoundation

enum HornTone: String, CaseIterable, Codable, Identifiable {
    case air = "エアホーン"
    case electronic = "電子ホーン"
    var id: String { rawValue }
}

/// 族のミュージックホーンをその場で合成して鳴らすエンジン。
/// サンプル音源を持たず、倍音加算合成でメロディ全体を1バッファに描画して再生する。
final class HornEngine: ObservableObject {
    @Published var isPlaying = false
    @Published var tone: HornTone = .air
    @Published var tempo: Double = 160
    @Published var loop = false

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44100
    private var configured = false

    private func configure() {
        guard !configured else { return }
        configured = true
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.prepare()
        try? engine.start()
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
        guard let buffer = renderBuffer(notes: notes) else { return }
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

    // MARK: - 合成

    private func renderBuffer(notes: [Int]) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        // tempo は4分音符BPM。ホーンは8分音符刻みで鳴らす。
        let secondsPerStep = 60.0 / max(tempo, 30) / 2.0
        let framesPerStep = Int(secondsPerStep * sampleRate)
        let totalFrames = framesPerStep * max(notes.count, 1)
        guard totalFrames > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalFrames)) else { return nil }
        buffer.frameLength = AVAudioFrameCount(totalFrames)
        let left = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        for i in 0..<totalFrames { left[i] = 0; right[i] = 0 }

        let gate = 0.85 // 発音長。残りは無音でパラリラの粒立ちを作る
        let noteFrames = Int(Double(framesPerStep) * gate)
        for (idx, note) in notes.enumerated() where note >= 0 {
            let freq = 440.0 * pow(2.0, (Double(note) - 69.0) / 12.0)
            renderNote(freq: freq, left: left, right: right,
                       start: idx * framesPerStep, length: noteFrames, total: totalFrames)
        }
        return buffer
    }

    private func harmonicProfile() -> [Double] {
        switch tone {
        case .air:
            // 真鍮的に倍音リッチ = エアホーンの厚み
            return [1.0, 0.8, 0.65, 0.5, 0.4, 0.32, 0.26, 0.2, 0.16, 0.12]
        case .electronic:
            // 奇数倍音強め = 電子ミュージックホーンの矩形波っぽさ
            return [1.0, 0.12, 0.55, 0.08, 0.35, 0.06, 0.24, 0.04, 0.17, 0.03]
        }
    }

    private func renderNote(freq: Double, left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>,
                            start: Int, length: Int, total: Int) {
        let harmonics = harmonicProfile()
        let detune = pow(2.0, (tone == .air ? 8.0 : 3.0) / 1200.0) // 左右で微デチューン=ツインホーンのうなり
        let freqL = freq
        let freqR = freq * detune
        let attack = 0.008 * sampleRate
        let release = 0.05 * sampleRate
        let vibratoRate = 5.5
        let vibratoDepth = tone == .air ? 0.004 : 0.002
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
        engine.stop()
    }
}
