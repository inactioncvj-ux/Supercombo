import Foundation

struct ChargerDataLoader {
    func loadBundledChargers() -> [ChargerStation] {
        let bundle = Bundle.main
        let candidates: [(String, String)] = [
            ("highway-dc-combo-product", "json"),
            ("chargers.sample", "json")
        ]

        for (name, ext) in candidates {
            if let url = bundle.url(forResource: name, withExtension: ext) {
                do {
                    let data = try Data(contentsOf: url)
                    if name == "highway-dc-combo-product" {
                        let decoded = try JSONDecoder().decode([ProductChargerDataset].self, from: data)
                        return decoded.map { $0.asChargerStation() }
                    } else {
                        return try JSONDecoder().decode([ChargerStation].self, from: data)
                    }
                } catch {
                    print("Failed to load \(name).\(ext): \(error)")
                }
            }
        }

        return []
    }
}
