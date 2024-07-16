// Copyright 2024 Google LLC. All rights reserved.
//
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.

import CoreLocation
import GooglePlacesSwift

/// The configurations use in various requests/samples.
class ParameterConfiguration: ObservableObject {
  @Published var placeTypesOption = PlaceTypesOption.unspecified
  @Published var locationOption = LocationOption.unspecified
  @Published var placeProperties = Set<PlaceProperty>(PlaceProperty.allCases)

  /// The autocompleteFilter for this configuration.
  var autocompleteFilter: AutocompleteFilter {
    let restriction: RectangularCoordinateRegion?
    if let northEast = locationOption.northEast, let southWest = locationOption.southWest {
      restriction = RectangularCoordinateRegion(
        northEast: northEast,
        southWest: southWest)
    } else {
      restriction = nil
    }
    return AutocompleteFilter(
      types: placeTypesOption.placeTypes,
      origin: locationOption.location,
      coordinateRegionRestriction: restriction)
  }

  /// The place types option for the autocomplete filter.
  enum PlaceTypesOption: String, Identifiable, CaseIterable {
    case unspecified
    case geocode
    case address
    case establishment
    case region
    case city

    var id: Self { self }

    /// Some higher-level place type options that are mapped to concrete sets of `PlaceType`.
    var placeTypes: Set<PlaceType>? {
      switch self {
      case .geocode:
        [.geocode]
      case .address:
        [.address]
      case .establishment:
        [.establishment]
      case .region:
        [.locality, .sublocality, .postalCode, .country, .administrativeAreaLevel1]
      case .city:
        [.locality, .administrativeAreaLevel3]
      default:
        nil
      }
    }
  }

  /// The location option for the autocomplete filter.
  enum LocationOption: String, Identifiable, CaseIterable {
    case unspecified
    case canada
    case kansas

    var id: Self { self }

    /// The northEast coodinate for this location.
    var northEast: CLLocationCoordinate2D? {
      switch self {
      case .canada:
        CLLocationCoordinate2D(latitude: 70.0, longitude: -60.0)
      case .kansas:
        CLLocationCoordinate2D(latitude: 39.0, longitude: -95.0)
      default:
        nil
      }
    }

    /// The southWest coodinate for this location.
    var southWest: CLLocationCoordinate2D? {
      switch self {
      case .canada:
        CLLocationCoordinate2D(latitude: 50.0, longitude: -140.0)
      case .kansas:
        CLLocationCoordinate2D(latitude: 37.5, longitude: -100.0)
      default:
        nil
      }
    }

    /// The `CLLocation` for this location.
    var location: CLLocation? {
      switch self {
      case .canada, .kansas:
        guard let northEast else {
          fatalError("Valid LocationOption doesn't have valid northEast coordinate: \(self).")
        }
        return CLLocation(latitude: northEast.latitude, longitude: northEast.longitude)
      default:
        return nil
      }
    }
  }
}
