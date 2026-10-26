//
//  PlaceResult.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 25/10/26.
//

import Foundation

struct PlaceResult: Identifiable, Sendable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let categories: [String]
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
