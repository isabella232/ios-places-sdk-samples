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
import SwiftUI

struct ConfigurationView: View {
  @ObservedObject var configuration: ParameterConfiguration
  // Note: This is a separate state and we use onChange(of:) to update `configuration` because of an
  // apparent bug where the MultiPicker gets popped after each change. Possibly related to
  // NavigationView? With min iOS 16 we can migrate to NavigationStack and possible remove this.
  @State var placeProperties: Set<PlaceProperty>

  init(configuration: ParameterConfiguration) {
    self.configuration = configuration
    self.placeProperties = configuration.placeProperties
  }

  var body: some View {
    List {
      Section("Autocomplete Filter") {
        Picker("Place Types", selection: $configuration.placeTypesOption) {
          ForEach(ParameterConfiguration.PlaceTypesOption.allCases) { placeTypesOption in
            Text(placeTypesOption.rawValue.capitalized)
          }
        }
        Picker("Origin", selection: $configuration.locationOption) {
          ForEach(ParameterConfiguration.LocationOption.allCases) { locationOption in
            Text(locationOption.rawValue.capitalized)
          }
        }
      }
      Section ("Place Properties") {
        MultiPicker(label: Text("Selections"),
                    options: PlaceProperty.allCases,
                    optionFormatter: { $0.description },
                    selectedOptions: $placeProperties)
        .onChange(of: placeProperties) { newValue in
          configuration.placeProperties = newValue
        }
      }
    }
  }
}

extension PlaceProperty: CustomStringConvertible, CaseIterable, Identifiable {
  public var id: Self { self }

  public static var allCases: [PlaceProperty] = [
    .accessibilityOptions,
    .addressComponents,
    .all,
    .businessStatus,
    .coordinate,
    .currentOpeningHours,
    .currentSecondaryOpeningHours,
    .displayName,
    .editorialSummary,
    .formattedAddress,
    .iconBackgroundColor,
    .iconMaskURL,
    .internationalPhoneNumber,
    .isReservable,
    .numberOfUserRatings,
    .photos,
    .placeID,
    .plusCode,
    .priceLevel,
    .rating,
    .regularOpeningHours,
    .reviews,
    .servesBeer,
    .servesBreakfast,
    .servesBrunch,
    .servesDinner,
    .servesLunch,
    .servesVegetarianFood,
    .servesWine,
    .supportsCurbsidePickup,
    .supportsDelivery,
    .supportsDineIn,
    .supportsTakeout,
    .timeZone,
    .types,
    .viewportInfo,
    .websiteURL,
  ]

  public var description: String {
    switch self {
    case .coordinate: return "Coordinate"
    case .displayName: return "Name"
    case .placeID: return "Place ID"
    case .plusCode: return "Plus Code"
    case .regularOpeningHours: return "Opening Hours"
    case .internationalPhoneNumber: return "Phone Number"
    case .formattedAddress: return "Formatted Address"
    case .rating: return "Rating"
    case .priceLevel: return "Price Level"
    case .types: return "Types"
    case .websiteURL: return "Website"
    case .viewportInfo: return "Viewport"
    case .addressComponents: return "Address Components"
    case .photos: return "Photos"
    case .numberOfUserRatings: return "User Ratings Total"
    case .timeZone: return "UTC Offset Minutes"
    case .businessStatus: return "Business Status"
    case .iconMaskURL: return "Icon Mask URL"
    case .iconBackgroundColor: return "Icon Background Color"
    case .supportsTakeout: return "Takeout"
    case .supportsDelivery: return "Delivery"
    case .supportsDineIn: return "Dine In"
    case .supportsCurbsidePickup: return "Curbside Pickup"
    case .isReservable: return "Reservable"
    case .servesBreakfast: return "Serves Breakfast"
    case .servesLunch: return "Serves Lunch"
    case .servesDinner: return "Serves Dinner"
    case .servesBeer: return "Serves Beer"
    case .servesWine: return "Serves Wine"
    case .servesBrunch: return "Serves Brunch"
    case .servesVegetarianFood: return "Serves Vegetarian Food"
    case .accessibilityOptions: return "Wheelchair Accessible Entrance"
    case .currentOpeningHours: return "Current Opening Hours"
    case .currentSecondaryOpeningHours: return "Secondary Opening Hours"
    case .editorialSummary: return "Editorial Summary"
    case .reviews: return "Reviews"
    case .all: return "All"
    default: return "Unknown Case"
    }
  }
}

#Preview {
  struct ConfigurationViewPreviewContainer: View {
    @StateObject private var configuration = ParameterConfiguration()

    var body: some View {
      NavigationView {
        ConfigurationView(configuration: configuration)
      }
    }
  }

  return ConfigurationViewPreviewContainer()
}
