import Foundation

struct HornStudioSettings: Codable, Equatable {
    var swing: Double = 0
    var gate: Double = 0.85
    var transpose: Int = 0
    var harmony: Int = 0
    var echo: Double = 0

    var sanitized: Self {
        var s = self
        s.swing = swing.isFinite ? min(0.5, max(0, swing)) : 0
        s.gate = gate.isFinite ? min(0.98, max(0.15, gate)) : 0.85
        s.transpose = min(24, max(-24, transpose))
        s.harmony = [0, 4, 7, 12].contains(harmony) ? harmony : 0
        s.echo = echo.isFinite ? min(0.6, max(0, echo)) : 0
        return s
    }
}

enum HornStudioDSP {
    static func boundaries(count: Int, tempo: Double, swing: Double, rate: Double = 44100) -> [Int] {
        let bpm = tempo.isFinite ? min(300, max(30, tempo)) : 160
        let base = 60 / bpm / 2 * rate
        let s = swing.isFinite ? min(0.5, max(0, swing)) : 0
        return (0...max(0, count)).map { index in
            Int((Double(index) * base + (index % 2 == 1 ? base * s : 0)).rounded())
        }
    }
    static func harmonics(_ voice: String) -> [Double] {
        switch voice {
        case "brass": return [1, 0.62, 0.4, 0.3, 0.18, 0.12, 0.07]
        case "glass": return [1, 0.03, 0.32, 0.02, 0.15, 0.01, 0.08]
        case "retro": return [1, 0, 0.45, 0, 0.25, 0, 0.12, 0, 0.07]
        case "velvet": return [1, 0.3, 0.13, 0.05]
        default: return [1, 0.12, 0.55, 0.08, 0.35, 0.06, 0.24, 0.04, 0.17, 0.03]
        }
    }
    static func generate(count: Int, seed: UInt64, mode: Int) -> [Int] {
        let scale = mode == 1 ? [60, 63, 65, 67, 70, 72] : [60, 62, 64, 67, 69, 72]
        var state = seed
        return (0..<count).map { i in
            state = state &* 6364136223846793005 &+ 1442695040888963407
            if i % 8 == 7 || (state >> 32) % 7 == 0 { return -1 }
            return scale[Int((state >> 32) % UInt64(scale.count))]
        }
    }
    /// Stereo cross-delay, zero-preserving saturation and DC removal shared by preview/export.
    static func finish(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, count: Int,
                       grit: Double, echo: Double, delayFrames: Int) {
        let g = grit.isFinite ? min(1, max(0, grit)) : 0
        let mix = echo.isFinite ? min(0.6, max(0, echo)) : 0
        let delay = max(1, delayFrames)
        if mix > 0 && delay < count {
            for i in delay..<count {
                let l = left[i - delay], r = right[i - delay]
                left[i] += r * Float(mix); right[i] += l * Float(mix)
            }
        }
        var inputL: Float = 0, inputR: Float = 0, outputL: Float = 0, outputR: Float = 0
        for i in 0..<count {
            let l = left[i].isFinite ? left[i] : 0, r = right[i].isFinite ? right[i] : 0
            let dcL = l - inputL + 0.995 * outputL, dcR = r - inputR + 0.995 * outputR
            inputL = l; inputR = r; outputL = dcL; outputR = dcR
            let fade = min(1, Float(min(i, count - 1 - i)) / 128)
            left[i] = tanh(dcL * Float(1 + 4.2 * g)) * Float(0.9 / (1 + 0.72 * g)) * fade
            right[i] = tanh(dcR * Float(1 + 4.2 * g)) * Float(0.9 / (1 + 0.72 * g)) * fade
        }
    }
}
