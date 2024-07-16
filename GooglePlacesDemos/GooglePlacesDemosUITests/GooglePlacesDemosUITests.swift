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

import XCTest

final class GooglePlacesDemosUITests: XCTestCase {

  override func setUpWithError() throws {
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
  }

  func testConfigurationPlacePropertiesMultiPicker() throws {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    app.launch()

    // Go to the configuration's Place Properties picker.
    app.navigationBars.buttons["Configure"].tap()
    let collectionViewsQuery = app.collectionViews
    collectionViewsQuery.staticTexts["Selections"].tap()

    // Deselect all, select some known cells, and verify the selection applied.
    app.navigationBars.buttons["Deselect All"].tap()
    collectionViewsQuery.buttons["Address Components"].tap()
    collectionViewsQuery.buttons["Business Status"].tap()
    collectionViewsQuery.buttons["Name"].tap()
    let backButton = app.navigationBars.buttons["Back"]
    backButton.tap()
    XCTAssert(
      collectionViewsQuery.staticTexts["Address Components, Business Status, and Name"].exists)
  }
}
