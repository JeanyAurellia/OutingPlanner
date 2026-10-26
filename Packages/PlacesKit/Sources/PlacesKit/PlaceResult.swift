import Foundation

public struct PlaceResult: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let categories: [String]

    public init(
        id: String,
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        categories: [String]
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.categories = categories
    }
}

struct GeoapifyResponse: Decodable {
    let features: [GeoapifyFeature]
}

struct GeoapifyFeature: Decodable {
    let properties: GeoapifyProperties
}

struct GeoapifyProperties: Decodable {
    let placeID: String
    let name: String?
    let formatted: String?
    let lat: Double
    let lon: Double
    let category: String?
    let categories: [String]?

    enum CodingKeys: String, CodingKey {
        case placeID = "place_id"
        case name, formatted, lat, lon, category, categories
    }
}
