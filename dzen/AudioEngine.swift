import AVFoundation
import Observation

@Observable
final class AudioEngine {
    var masterVolume: Float = 0.75 {
        didSet { engine.mainMixerNode.outputVolume = masterVolume }
    }

    private(set) var activeSounds: Set<String> = []
    private var volumes: [String: Float] = [:]

    private let engine = AVAudioEngine()
    private var players: [String: AVAudioPlayerNode] = [:]
    private var buffers: [String: AVAudioPCMBuffer] = [:]

    init() {
        engine.mainMixerNode.outputVolume = masterVolume
    }

    func isPlaying(_ id: String) -> Bool {
        activeSounds.contains(id)
    }

    func volume(for id: String) -> Float {
        volumes[id] ?? 0.5
    }

    func setVolume(for id: String, to value: Float) {
        volumes[id] = value
        players[id]?.volume = value
    }

    func toggle(_ sound: Sound) {
        if activeSounds.contains(sound.id) {
            stop(sound)
        } else {
            play(sound)
        }
    }

    func stopAll() {
        for id in activeSounds {
            players[id]?.stop()
        }
        activeSounds.removeAll()
    }

    private func play(_ sound: Sound) {
        let player = ensureLoaded(sound)

        if !engine.isRunning {
            try? engine.start()
        }

        player.stop()
        player.scheduleBuffer(buffers[sound.id]!, at: nil, options: .loops)
        player.volume = volumes[sound.id] ?? 0.5
        player.play()
        activeSounds.insert(sound.id)
    }

    private func stop(_ sound: Sound) {
        players[sound.id]?.stop()
        activeSounds.remove(sound.id)
    }

    @discardableResult
    private func ensureLoaded(_ sound: Sound) -> AVAudioPlayerNode {
        if let player = players[sound.id] {
            return player
        }

        let url = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3")!
        let file = try! AVAudioFile(forReading: url)
        let format = file.processingFormat
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
        try! file.read(into: buffer)

        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        players[sound.id] = player
        buffers[sound.id] = buffer
        if volumes[sound.id] == nil { volumes[sound.id] = 0.5 }

        return player
    }
}
