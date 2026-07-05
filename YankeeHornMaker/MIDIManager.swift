import Foundation
import CoreMIDI
import SwiftUI

/// 外部MIDI機器（USB/BluetoothのMIDIキーボード等）からノートオンを受信する。
final class MIDIManager: ObservableObject {
    @Published var isConnected = false
    @Published var lastNote: Int = -1
    /// ノートオンのたびに増える。UI側の`onChange`検知に使う。
    @Published var noteCount: Int = 0

    /// ノートオン時に呼ばれる。ライブ発音の配線に使う。
    var onNoteOn: ((Int) -> Void)?

    private var client = MIDIClientRef()
    private var port = MIDIPortRef()
    private var started = false

    func start() {
        guard !started else { return }
        started = true
        MIDIClientCreateWithBlock("YankeeHornClient" as CFString, &client) { [weak self] _ in
            self?.connectAllSources()
        }
        MIDIInputPortCreateWithProtocol(client, "YankeeHornIn" as CFString, ._1_0, &port) { [weak self] eventList, _ in
            self?.receive(eventList)
        }
        connectAllSources()
    }

    private func connectAllSources() {
        let count = MIDIGetNumberOfSources()
        for i in 0..<count {
            MIDIPortConnectSource(port, MIDIGetSource(i), nil)
        }
        DispatchQueue.main.async { self.isConnected = count > 0 }
    }

    private func receive(_ eventList: UnsafePointer<MIDIEventList>) {
        let list = eventList.pointee
        var packet = list.packet
        for _ in 0..<list.numPackets {
            let count = Int(packet.wordCount)
            withUnsafePointer(to: packet.words) { tuplePtr in
                tuplePtr.withMemoryRebound(to: UInt32.self, capacity: count) { words in
                    for i in 0..<count {
                        let word = words[i]
                        // MIDI 1.0 チャンネルボイスメッセージ（メッセージタイプ 0x2）だけ扱う
                        guard (word >> 28) & 0xF == 0x2 else { continue }
                        let status = (word >> 16) & 0xF0
                        let note = Int((word >> 8) & 0x7F)
                        let velocity = Int(word & 0x7F)
                        if status == 0x90 && velocity > 0 {
                            emit(note)
                        }
                    }
                }
            }
            packet = MIDIEventPacketNext(&packet).pointee
        }
    }

    private func emit(_ note: Int) {
        DispatchQueue.main.async {
            self.lastNote = note
            self.noteCount &+= 1
            self.onNoteOn?(note)
        }
    }
}

/// 書き出したファイルを共有シートで渡すためのラッパ。
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
