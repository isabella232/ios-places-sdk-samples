//
//  GooglePlacesDemosApp.swift
//  GooglePlacesDemos
//
//  Created by Jakob Adams on 4/17/24.
//

import GooglePlacesSwift
import SwiftUI

@main
struct GooglePlacesDemosApp: App {
  init() {
    guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else {
      fatalError("Info.plist not found")
    }
    guard let apiKey: String = infoDictionary["API_KEY"] as? String else {
      // To use GooglePlacesDemos, please register an API Key for your application, set it in an
      // xcconfig file, and use that config file for the configuration being built (Debug). Your
      // API Key should be kept private and not be checked in.
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
