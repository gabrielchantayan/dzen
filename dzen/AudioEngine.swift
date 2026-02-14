import AVFoundation
import Observation

@Observable
final class AudioEngine {
    var masterVolume: Float = 0.75 {
        didSet { engine.mainMixerNode.outputVolume = masterVolume }
    }

    private(set) var activeSounds: Set<String> = []
    private(set) var loadingSounds: Set<String> = []
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

    func isLoading(_ id: String) -> Bool {
        loadingSounds.contains(id)
    }

    func toggle(_ sound: Sound) {
        if activeSounds.contains(sound.id) {
            stop(sound)
        } else {
            play(sound)
        }
    }

    func stopAll() {
        loadingSounds.removeAll()

        for (_, player) in players {
            player.stop()
            engine.detach(player)
        }

        players.removeAll()
        buffers.removeAll()
        activeSounds.removeAll()

        if engine.isRunning {
            engine.stop()
        }
    }

    private func play(_ sound: Sound) {
        if players[sound.id] != nil {
            startPlayer(sound)
            return
        }

        loadingSounds.insert(sound.id)

        Task.detached { [self] in
            let url = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3")!
            let file = try! AVAudioFile(forReading: url)
            let format = file.processingFormat
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
            try! file.read(into: buffer)

            await MainActor.run {
                guard loadingSounds.contains(sound.id) else { return }

                let player = AVAudioPlayerNode()
                engine.attach(player)
                engine.connect(player, to: engine.mainMixerNode, format: format)

                players[sound.id] = player
                buffers[sound.id] = buffer
                if volumes[sound.id] == nil { volumes[sound.id] = 0.5 }

                loadingSounds.remove(sound.id)
                startPlayer(sound)
            }
        }
    }

    private func startPlayer(_ sound: Sound) {
        guard let player = players[sound.id], let buffer = buffers[sound.id] else { return }

        if !engine.isRunning {
            try? engine.start()
        }

        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        player.volume = volumes[sound.id] ?? 0.5
        player.play()
        activeSounds.insert(sound.id)
    }

    private func stop(_ sound: Sound) {
        loadingSounds.remove(sound.id)

        if let player = players[sound.id] {
            player.stop()
            engine.detach(player)
        }

        players.removeValue(forKey: sound.id)
        buffers.removeValue(forKey: sound.id)
        activeSounds.remove(sound.id)

        if activeSounds.isEmpty && engine.isRunning {
            engine.stop()
        }
    }
}
