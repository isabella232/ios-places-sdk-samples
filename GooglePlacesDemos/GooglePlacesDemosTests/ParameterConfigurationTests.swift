//
//  ParameterConfigurationTests.swift
//  GooglePlacesDemosTests
//
//  Created by Jakob Adams on 7/1/24.
//

import CoreLocation
import GooglePlacesSwift
import XCTest

@testable import GooglePlacesDemos

final class ParameterConfigurationTests: XCTestCase {
  func testDefaultAutocompleteFilter() {
    let configuration = ParameterConfiguration()
    XCTAssertEqual(configuration.placeTypesOption, .unspecified)
    XCTAssertEqual(configuration.locationOption, .unspecified)
    XCTAssertEqual(configuration.placeProperties, Set<PlaceProperty>(PlaceProperty.allCases))
  }

  func testLocationOptionConsistency() {
    // Case: .unspecified
    var unspecified: ParameterConfiguration.LocationOption = .unspecified
    XCTAssertNil(unspecified.northEast)
    XCTAssertNil(unspecified.southWest)
    XCTAssertNil(unspecified.location)

    // Case: .canada
    let canada: ParameterConfiguration.LocationOption = .canada
    XCTAssertEqual(canada.location?.coordinate, canada.northEast)

    // Case: .kansas
    let kansas: ParameterConfiguration.LocationOption = .kansas
    XCTAssertEqual(kansas.location?.coordinate, kansas.northEast)

    // .canada != .kansas
    XCTAssertNotEqual(canada.northEast, kansas.northEast)
    XCTAssertNotEqual(canada.southWest, kansas.southWest)
    XCTAssertNotEqual(canada.location, kansas.location)
  }
}

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}
