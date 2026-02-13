import Foundation
import Observation

@Observable
final class UpdateChecker {
    var updateAvailable = false
    var remoteVersionString = ""

    private var timer: Timer?

    private struct RemoteVersion: Decodable {
        let major: Int
        let minor: Int
    }

    init() {
        Task { await check() }
        timer = Timer.scheduledTimer(withTimeInterval: 43200, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.check() }
        }
    }

    private func check() async {
        guard let url = URL(string: "https://raw.githubusercontent.com/gabrielchantayan/dzen/master/version.json") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let remote = try JSONDecoder().decode(RemoteVersion.self, from: data)
            let localVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
            let parts = localVersion.split(separator: ".").compactMap { Int($0) }
            let localMajor = parts.count > 0 ? parts[0] : 0
            let localMinor = parts.count > 1 ? parts[1] : 0
            await MainActor.run {
                updateAvailable = (remote.major, remote.minor) > (localMajor, localMinor)
                remoteVersionString = "\(remote.major).\(remote.minor)"
            }
        } catch {
            // Silently ignore — no update banner on failure
        }
    }
}
