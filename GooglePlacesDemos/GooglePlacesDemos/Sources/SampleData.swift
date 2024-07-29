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

import UIKit
import SwiftUI

/// Represents an individual sample that can either be SwiftUI based or UIKit based.
struct Sample: Hashable {
  enum ViewType: Hashable {
    case swiftUI(any View)
    case uiKit(UIViewController.Type)

    static func == (lhs: Sample.ViewType, rhs: Sample.ViewType) -> Bool {
      switch (lhs, rhs) {
      case (.swiftUI(let lhsView), swiftUI(let rhsView)):
        return type(of: lhsView) == type(of: rhsView)
      case (.uiKit(let lhsViewControllerType), uiKit(let rhsViewControllerType)):
        return lhsViewControllerType == rhsViewControllerType
      default:
        return false
      }
    }

    func hash(into hasher: inout Hasher) {
      switch self {
      case .swiftUI(let view):
        hasher.combine(String(describing: view))
      case .uiKit(let viewControllerType):
        hasher.combine(String(describing: viewControllerType))
      }
    }
  }

  let viewType: ViewType
  let title: String
}

/// A collection of samples.
struct SampleSection: Hashable {
  let name: String
  let samples: [Sample]
}

/// Namespaced collections of samples for easy creation.
enum Samples {
  static func allSampleSections() -> [SampleSection] {
    let placesSwiftSamples: [Sample] = [
      Sample(viewType: .swiftUI(ClientRequests()), title: "Client Requests")
    ]
    let placesSamples: [Sample] = [
      Sample(viewType: .uiKit(SearchNearbyViewController.self), title: "Search Nearby")
    ]
    return [
      SampleSection(name: "GooglePlacesSwift Samples", samples: placesSwiftSamples),
      SampleSection(name: "GooglePlaces Samples", samples: placesSamples),
    ]
  }
}
