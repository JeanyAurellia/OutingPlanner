import Foundation
import Testing
@testable import PlacesKit

@Test
func decodesSingularGeocodingCategory() throws {
    let data = Data(
        """
        {
          "features": [
            {
              "properties": {
                "place_id": "mall-1",
                "name": "Example Mall",
                "formatted": "Jakarta, Indonesia",
                "lat": -6.2,
                "lon": 106.8,
                "category": "commercial.shopping_mall"
              }
            }
          ]
        }
        """.utf8
    )

    let places = try GeoapifyPlaceService.decodePlaces(from: data)

    #expect(places.count == 1)
    #expect(places[0].categories == ["commercial.shopping_mall"])
}

@Test
func decodesPluralPlacesCategories() throws {
    let data = Data(
        """
        {
          "features": [
            {
              "properties": {
                "place_id": "cafe-1",
                "name": "Example Cafe",
                "formatted": "Jakarta, Indonesia",
                "lat": -6.2,
                "lon": 106.8,
                "categories": ["catering", "catering.cafe"]
              }
            }
          ]
        }
        """.utf8
    )

    let places = try GeoapifyPlaceService.decodePlaces(from: data)

    #expect(places.count == 1)
    #expect(places[0].categories == ["catering", "catering.cafe"])
}
