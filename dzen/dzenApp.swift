import SwiftUI

@main
struct dzenApp: App {
    @State private var engine = AudioEngine()
    @State private var updateChecker = UpdateChecker()

    var body: some Scene {
        MenuBarExtra("dzen", systemImage: "waveform") {
            ContentView(engine: engine, updateChecker: updateChecker)
        }
        .menuBarExtraStyle(.window)
    }
}
