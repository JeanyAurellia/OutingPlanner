//
//  OutingPlannerTests.swift
//  OutingPlannerTests
//
//  Created by Jeany Aurellia on 17/06/26.
//

import Foundation
import PlacesKit
import Testing

@Test
@MainActor
func recommendationReturnsPlaces() async throws {
    let apiKey = try #require(
        ProcessInfo.processInfo.environment["GEOAPIFY_API_KEY"]
    )

    let service = PlacesKit.GeoapifyPlaceService(apiKey: apiKey)

    let results = try await service.recommendPlaces(
        latitude: -6.2088,
        longitude: 106.8456,
        radius: 5_000
    )

    for place in results {
        print("""
        Nama: \(place.name)
        Alamat: \(place.address)
        Koordinat: \(place.latitude), \(place.longitude)
        Kategori: \(place.categories)
        ---
        """)

    }

    dump(results)

    #expect(!results.isEmpty)
}
