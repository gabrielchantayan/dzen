import Foundation

struct Sound: Identifiable {
    let id: String
    let displayName: String
    let fileName: String
    let category: Category

    enum Category: String, CaseIterable {
        case nature = "Nature"
        case city = "City"
        case cafe = "Cafe"
        case cozy = "Cozy"
        case noise = "Noise"
    }

    static let all: [Sound] = [
        Sound(id: "beach", displayName: "Beach", fileName: "beach_audio", category: .nature),
        Sound(id: "cicadas", displayName: "Cicadas", fileName: "cicadas_audio", category: .nature),
        Sound(id: "crickets", displayName: "Crickets", fileName: "crickets_audio", category: .nature),
        Sound(id: "forest_stream", displayName: "Forest Stream", fileName: "forest_stream_audio", category: .nature),
        Sound(id: "nightingale", displayName: "Nightingale", fileName: "nightingale_audio", category: .nature),
        Sound(id: "nighttime", displayName: "Nighttime", fileName: "nighttime_audio", category: .nature),
        Sound(id: "rain", displayName: "Rain", fileName: "rain_audio", category: .nature),
        Sound(id: "thunder", displayName: "Thunder", fileName: "thunder_audio", category: .nature),

        Sound(id: "cars_passing", displayName: "Cars Passing", fileName: "cars_passing_audio", category: .city),
        Sound(id: "dutch_neighborhood", displayName: "Dutch Neighborhood", fileName: "dutch_neighborhood_audio", category: .city),
        Sound(id: "moscow_subway", displayName: "Moscow Subway", fileName: "moscow_subway_audio", category: .city),
        Sound(id: "nyc_subway", displayName: "NYC Subway", fileName: "nyc_subway_audio", category: .city),
        Sound(id: "subway", displayName: "Subway", fileName: "subway", category: .city),
        Sound(id: "yamanote_line", displayName: "Yamanote Line", fileName: "yamanote_line_audio", category: .city),
        Sound(id: "yerevan_metro", displayName: "Yerevan Metro", fileName: "yerevanskoe_metro_audio", category: .city),

        Sound(id: "french_cafe", displayName: "French Cafe", fileName: "french_cafe_audio", category: .cafe),
        Sound(id: "seoul_cafe", displayName: "Seoul Cafe", fileName: "seoul_cafe_audio", category: .cafe),

        Sound(id: "fireplace", displayName: "Fireplace", fileName: "fireplace_audio", category: .cozy),

        Sound(id: "brown_noise", displayName: "Brown Noise", fileName: "brown_noise_audio", category: .noise),
        Sound(id: "white_noise", displayName: "White Noise", fileName: "white_noise_audio", category: .noise),
    ]

    static var byCategory: [(Category, [Sound])] {
        Category.allCases.compactMap { category in
            let sounds = all.filter { $0.category == category }
            return sounds.isEmpty ? nil : (category, sounds)
        }
    }
}
