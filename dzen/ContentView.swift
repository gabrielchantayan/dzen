import SwiftUI
import AppKit

struct ContentView: View {
    var engine: AudioEngine

    var body: some View {
        VStack(spacing: 0) {
            header
            masterVolume
            Divider()
            soundList
            Divider()
            footer
        }
        .frame(width: 280, height: 500)
    }

    private var header: some View {
        HStack {
            Text("dzen")
                .font(.headline)
            Spacer()
            Button("Stop All") { engine.stopAll() }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var masterVolume: some View {
        HStack(spacing: 8) {
            Image(systemName: "speaker.fill")
                .foregroundStyle(.secondary)
            Slider(
                value: Binding(
                    get: { engine.masterVolume },
                    set: { engine.masterVolume = $0 }
                ),
                in: 0...1 as ClosedRange<Float>
            )
            Image(systemName: "speaker.wave.3.fill")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    private var soundList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Sound.byCategory, id: \.0) { category, sounds in
                    SoundCategoryView(category: category, sounds: sounds, engine: engine)
                }
            }
            .padding()
        }
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button("Quit") { NSApplication.shared.terminate(nil) }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct SoundCategoryView: View {
    let category: Sound.Category
    let sounds: [Sound]
    var engine: AudioEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(category.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ForEach(sounds) { sound in
                SoundRowView(sound: sound, engine: engine)
            }
        }
    }
}

struct SoundRowView: View {
    let sound: Sound
    var engine: AudioEngine

    private var isActive: Bool { engine.isPlaying(sound.id) }

    var body: some View {
        HStack(spacing: 8) {
            Button { engine.toggle(sound) } label: {
                Image(systemName: isActive ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .foregroundStyle(isActive ? .primary : .tertiary)
                    .frame(width: 20)
            }
            .buttonStyle(.plain)

            Text(sound.displayName)
                .foregroundStyle(isActive ? .primary : .secondary)

            if isActive {
                Slider(
                    value: Binding(
                        get: { engine.volume(for: sound.id) },
                        set: { engine.setVolume(for: sound.id, to: $0) }
                    ),
                    in: 0...1 as ClosedRange<Float>
                )
            }

            Spacer(minLength: 0)
        }
    }
}
