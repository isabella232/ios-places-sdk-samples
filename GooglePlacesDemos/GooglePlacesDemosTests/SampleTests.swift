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

import SwiftUI
import XCTest

@testable import GooglePlacesDemos

final class SampleTests: XCTestCase {
  func testSwiftUISamplesEqual() {
    let sample1 = Sample(viewType: .swiftUI(ClientRequests()), title: "Test")
    let sample2 = Sample(viewType: .swiftUI(ClientRequests()), title: "Test")
    XCTAssertEqual(sample1, sample2)
  }

  func testSwiftUISamplesNotEqual() {
    let sample1 = Sample(viewType: .swiftUI(ClientRequests()), title: "Test")
    let sample2 = Sample(viewType: .swiftUI(Text("Test")), title: "Test")
    XCTAssertNotEqual(sample1, sample2)
  }

  func testUIKitSamplesEqual() {
    let sample1 = Sample(viewType: .uiKit(UITableViewController.self), title: "Test")
    let sample2 = Sample(viewType: .uiKit(UITableViewController.self), title: "Test")
    XCTAssertEqual(sample1, sample2)
  }

  func testUIKitSamplesNotEqual() {
    let sample1 = Sample(viewType: .uiKit(UITableViewController.self), title: "Test")
    let sample2 = Sample(viewType: .uiKit(UIViewController.self), title: "Test")
    XCTAssertNotEqual(sample1, sample2)
  }

  func testSamplesNotEqual() {
    let sample1 = Sample(viewType: .swiftUI(ClientRequests()), title: "Test")
    let sample2 = Sample(viewType: .uiKit(UIViewController.self), title: "Test")
    XCTAssertNotEqual(sample1, sample2)
  }
}
