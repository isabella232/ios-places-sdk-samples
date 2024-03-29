// Copyright 2020 Google LLC. All rights reserved.
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
import Foundation

/// A simple manager to handle location authorization and allow observing changes to the
///`authorizationStatus`` and potential errors.
class LocationDataManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  var locationManager = CLLocationManager()
  @Published var authorizationStatus: CLAuthorizationStatus?
  @Published var error: Error?
  @Published var hasError: Bool = false

  override init() {
    super.init()
    locationManager.delegate = self
  }

  // MARK: - CLLocationManagerDelegate

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
    if authorizationStatus == .notDetermined {
      manager.requestWhenInUseAuthorization()
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.error = error
    self.hasError = true
  }
}
