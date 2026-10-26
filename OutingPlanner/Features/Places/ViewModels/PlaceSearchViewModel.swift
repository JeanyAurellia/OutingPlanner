//
//  PlaceSearchViewModel.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 25/10/26.
//
import Observation
import Foundation

@MainActor
@Observable

final class PlaceSearchViewModel {
    var searchText = ""
    var places: [PlaceResult] = []
    var isLoading = false
    var errorMessage: String?

    private let service: GeoapifyPlaceService

        init(service: GeoapifyPlaceService) {
            self.service = service
        }

        func search() async {
            isLoading = true
            errorMessage = nil

            defer { isLoading = false }

            do {
                places = try await service.searchPlaces(query: searchText)
            } catch {
                errorMessage = error.localizedDescription
            }
        }

        func loadRecommendations(
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
