import Foundation
import AVFoundation
let legacy = Data("{\"id\":\"00000000-0000-0000-0000-000000000001\",\"name\":\"Old\",\"notes\":[60,-1,67],\"tempo\":180,\"tone\":\"リアルホーン\"}".utf8)
let old = try JSONDecoder().decode(SavedMelody.self, from: legacy)
assert(old.studio == nil && old.notes == [60,-1,67])
var settings = HornStudioSettings(); settings.swing = 0.42; settings.echo = 0.35; settings.harmony = 7
let melody = SavedMelody(name: "Studio", notes: Array(repeating: 60, count: 64), tempo: 155, tone: "クリスタル", studio: settings, grit: 0.3, humanFeel: 0.4)
let restored = try JSONDecoder().decode(SavedMelody.self, from: JSONEncoder().encode(melody))
assert(restored.notes.count == 64 && restored.studio == settings && restored.grit == 0.3)
for bpm in [80.0, 155, 260] {
    for count in [16,32,64] {
        let straight = HornStudioDSP.boundaries(count: count, tempo: bpm, swing: 0)
        let swung = HornStudioDSP.boundaries(count: count, tempo: bpm, swing: 0.5)
        assert(straight.last == swung.last)
        assert(zip(swung, swung.dropFirst()).allSatisfy { $0 < $1 })
        assert(abs(Double(straight.last!) - Double(count) * 30 / bpm * 44100) <= 0.5)
    }
}
assert(HornStudioDSP.generate(count: 64, seed: 42, mode: 0) == HornStudioDSP.generate(count: 64, seed: 42, mode: 0))
assert(HornStudioDSP.generate(count: 64, seed: 42, mode: 0) != HornStudioDSP.generate(count: 64, seed: 43, mode: 0))
let profiles = ["brass", "glass", "retro", "velvet"].map { HornStudioDSP.harmonics($0) }
assert(Set(profiles).count == 4)
func process(_ input: [Float], grit: Double, echo: Double) -> ([Float], [Float]) {
    var l = input, r = input
    let count = input.count
    l.withUnsafeMutableBufferPointer { lp in r.withUnsafeMutableBufferPointer { rp in
        HornStudioDSP.finish(left: lp.baseAddress!, right: rp.baseAddress!, count: count, grit: grit, echo: echo, delayFrames: 100)
    } }
    return (l,r)
}
let silent = process(Array(repeating: 0, count: 1000), grit: 1, echo: 0.6)
assert(silent.0.allSatisfy { $0 == 0 } && silent.1.allSatisfy { $0 == 0 })
let hot = process((0..<44100).map { Float(sin(Double($0) * 0.1) * 20) }, grit: 1, echo: 0.6)
assert((hot.0 + hot.1).allSatisfy { $0.isFinite && abs($0) < 1 })
assert(hot.0.first == 0 && hot.0.last == 0)
var invalid = settings; invalid.swing = .nan; invalid.transpose = 1000; invalid.harmony = 1000
assert(invalid.sanitized.swing == 0 && invalid.sanitized.transpose == 24 && invalid.sanitized.harmony == 0)
print("PASS: legacy saved melodies, complete studio round trip, 64 steps, swing timing, distinct voices, phrase generation, silent rests, headroom and edge fades")

// Exercise the actual production renderer and file encoder, without audio playback.
let engine = HornEngine()
engine.grit = 0.4; engine.humanFeel = 0; engine.studio = settings
for tone in [HornTone.brass, .glass, .retro, .velvet] {
    let buffer = engine.renderBuffer(notes: [60,64,67,-1,72,67,64,-1], tempo: 160, tone: tone)!
    let frames = Int(buffer.frameLength)
    let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: frames))
    assert(samples.allSatisfy { $0.isFinite && abs($0) < 1 })
    assert(samples.contains { abs($0) > 0.01 })
    let url = engine.export(notes: [60,64,67,-1,72,67,64,-1], tempo: 160, tone: tone, name: "studio-" + tone.synthesisVoice, format: .wav)!
    let file = try AVAudioFile(forReading: url)
    assert(file.length == buffer.frameLength && file.fileFormat.channelCount == 2)
    try FileManager.default.createDirectory(atPath: "studio-audio", withIntermediateDirectories: true)
    try Data(contentsOf: url).write(to: URL(fileURLWithPath: "studio-audio/" + url.lastPathComponent))
}
print("PASS: four production synth voices render and export valid stereo WAV files")
