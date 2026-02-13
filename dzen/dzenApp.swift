import SwiftUI

@main
struct dzenApp: App {
    @State private var engine = AudioEngine()

    var body: some Scene {
        MenuBarExtra("dzen", systemImage: "waveform") {
            ContentView(engine: engine)
        }
        .menuBarExtraStyle(.window)
    }
}
