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

import GooglePlacesSwift
import SwiftUI

@main
struct GooglePlacesDemosApp: App {
  init() {
    guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else {
      fatalError("Info.plist not found")
    }
    guard let apiKey: String = infoDictionary["API_KEY"] as? String else {
      // To use GooglePlacesDemos, please register an API Key for your application. Your API Key
      // should be kept private and not be checked in.
      //
      // Create an xcconfig file for your API key. By default the file should be named
      // "GooglePlacesDemos.xcconfig" and be located at the same directory level as the demo
      // application's "Info.plist" file. The contents of this file should contain at least a line
      // like `API_KEY = <insert your API key here>`.
      //
      // See documentation on getting an API Key for your API Project here:
      // https://developers.google.com/places/ios-sdk/start#get-key
      fatalError("API_KEY not set in Info.plist")
    }
    let _ = PlacesClient.provideAPIKey(apiKey)

    // Log the required open source licenses! Yes, just NSLog-ing them is not enough but is good
    // for a demo.
    print("Google Places Swift open source licenses:\n%@", PlacesClient.openSourceLicenseInfo)
  }
  var body: some Scene {
    WindowGroup {
      SampleList()
    }
  }
}
