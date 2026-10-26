import Foundation

public struct GeoapifyPlaceService: Sendable {
    private let apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func searchPlaces(query: String) async throws -> [PlaceResult] {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanQuery.isEmpty else {
            return []
        }

        guard var components = URLComponents(
            string: "https://api.geoapify.com/v1/geocode/search"
        ) else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(name: "text", value: cleanQuery),
            URLQueryItem(name: "format", value: "geojson"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "lang", value: "id"),
            URLQueryItem(name: "filter", value: "countrycode:id"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        return try await fetchPlaces(from: url)
    }

    public func recommendPlaces(
        latitude: Double,
        longitude: Double,
        radius: Int
    ) async throws -> [PlaceResult] {
        guard var components = URLComponents(
            string: "https://api.geoapify.com/v2/places"
        ) else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(
                name: "categories",
                value: "catering,entertainment,tourism,commercial"
            ),
            URLQueryItem(
                name: "filter",
                value: "circle:\(longitude),\(latitude),\(radius)"
            ),
            URLQueryItem(
                name: "bias",
                value: "proximity:\(longitude),\(latitude)"
            ),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        return try await fetchPlaces(from: url)
    }

    private func fetchPlaces(from url: URL) async throws -> [PlaceResult] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try Self.decodePlaces(from: data)
    }

    static func decodePlaces(from data: Data) throws -> [PlaceResult] {
        let response = try JSONDecoder().decode(
            GeoapifyResponse.self,
            from: data
        )

        return response.features.map { feature in
            let properties = feature.properties

            return PlaceResult(
                id: properties.placeID,
                name: properties.name ?? "Unknown Place",
                address: properties.formatted ?? "",
                latitude: properties.lat,
                longitude: properties.lon,
                categories: properties.categories
                    ?? properties.category.map { [$0] }
                    ?? []
            )
        }
    }
}
