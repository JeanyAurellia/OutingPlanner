import Foundation
import Observation

@MainActor
@Observable
public final class PlaceSearchViewModel {
    public var searchText = ""
    public var places: [PlaceResult] = []
    public var isLoading = false
    public var errorMessage: String?

    private let service: GeoapifyPlaceService

    public init(service: GeoapifyPlaceService) {
        self.service = service
    }

    public func search() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            places = try await service.searchPlaces(query: searchText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func loadRecommendations(
        latitude: Double,
        longitude: Double
    ) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            places = try await service.recommendPlaces(
                latitude: latitude,
                longitude: longitude,
                radius: 5_000
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
