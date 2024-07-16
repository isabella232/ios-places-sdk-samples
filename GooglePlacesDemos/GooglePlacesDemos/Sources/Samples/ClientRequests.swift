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

/// Demonstrates the main requests that can be made using `PlacesClient`.
///
/// The `Client Requests` section is likely to be the most useful for demonstration purposes as this
/// is where the requests on `PlacesClient` are actually made. The rest of the code is to
/// facilitate getting input and displaying the results.
struct ClientRequests: View {
  @Environment(\.parameterConfiguration) var parameterConfiguration

  @State private var onDismissInput: () -> Void = {}
  @State private var shouldShowInput = false
  @State private var inputDismissedViaDoneButton = false
  @State private var inputModel = InputModel()
  @State private var resultsModel = ResultsModel()
  @State private var errorAlertDescription = ""
  @State private var shouldPresentError = false

  @MainActor
  private static var placesClient = PlacesClient.shared

  private var clientRequests: some View {
    Menu("Client Requests") {
      Button("Fetch Place", action: fetchPlace)
      Button("Fetch Photo") { fetchPhoto() }
      Button("Find Autocomplete Suggestions", action: findAutocompleteSuggestions)
      Button("Is Open with Place ID", action: isOpenWithPlaceID)
      Button("Is Open with Place", action: isOpenWithPlace)
      Button("Search by Text", action: searchByText)
      Button("Search Nearby", action: searchNearby)
    }
  }

  var body: some View {
    Results(resultsModel: $resultsModel)
      .toolbar {
        clientRequests
      }
      .sheet(isPresented: $shouldShowInput, onDismiss: onDismissInput) {
        Input(
          inputModel: $inputModel,
          shouldShowInput: $shouldShowInput,
          inputDismissedViaDoneButton: $inputDismissedViaDoneButton)
      }
      .alert(isPresented: $shouldPresentError) {
        Alert(
          title: Text("Error"),
          message: Text(errorAlertDescription)
        )
      }
  }

  // MARK: - Client Requests

  private func fetchPlace() {
    shouldShowInput = true
    inputModel.options = [.placeID, .properties]
    onDismissInput = {
      guard inputDismissedViaDoneButton else { return }
      resultsModel = ResultsModel()
      let properties =
        inputModel.useProperties ? Array(parameterConfiguration.placeProperties) : []
      let fetchPlaceRequest = FetchPlaceRequest(
        placeID: inputModel.placeID,
        placeProperties: properties
      )
      Task {
        switch await Self.placesClient.fetchPlace(with: fetchPlaceRequest) {
        case .success(let place):
          resultsModel = ResultsModel(place: place)
        case .failure(let placesError):
          errorAlertDescription = placesError.localizedDescription
          shouldPresentError = true
        }
      }
    }
  }

  private func fetchPhoto() {
    shouldShowInput = true
    inputModel.options = [.photo, .size]
    onDismissInput = {
      guard inputDismissedViaDoneButton else { return }
      resultsModel = ResultsModel()
      guard let photo = inputModel.photo else {
        errorAlertDescription =
        "No photo metadata or size was selected. If the photo metadata list was empty try "
        + "fetching a place first!"
        shouldPresentError = true
        return
      }
      let fetchPhotoRequest =
      FetchPhotoRequest(photo: photo, maxSize: inputModel.size)
      Task {
        switch await Self.placesClient.fetchPhoto(with: fetchPhotoRequest) {
        case .success(let uiImage):
          resultsModel = ResultsModel(image: Image(uiImage: uiImage))
        case .failure(let placesError):
          errorAlertDescription = placesError.localizedDescription
          shouldPresentError = true
        }
      }
    }
  }

  private func findAutocompleteSuggestions() {
    shouldShowInput = true
    inputModel.options = [.query, .filter]
    onDismissInput = {
      guard inputDismissedViaDoneButton else { return }
      resultsModel = ResultsModel()
      let autocompleteRequest = AutocompleteRequest(
        query: inputModel.query, sessionToken: nil,
        filter: inputModel.useFilter ? parameterConfiguration.autocompleteFilter : nil)
      Task {
        switch await Self.placesClient.fetchAutocompleteSuggestions(with: autocompleteRequest) {
        case .success(let autocompleteSuggestions):
          resultsModel = ResultsModel(suggestions: autocompleteSuggestions)
        case .failure(let placesError):
          errorAlertDescription = placesError.localizedDescription
          shouldPresentError = true
        }
      }
    }
  }

  private func isOpenWithPlaceID() {
    shouldShowInput = true
    inputModel.options = [.placeID, .date]
    onDismissInput = {
      guard inputDismissedViaDoneButton else { return }
      resultsModel = ResultsModel()
      Task {
        switch await Self.placesClient.isPlaceOpen(inputModel.placeID, date: inputModel.date)
        {
        case .success(let isOpen):
          resultsModel = ResultsModel(displayIsOpen: true, isOpen: isOpen)
        case .failure(let placesError):
          errorAlertDescription = placesError.localizedDescription
          shouldPresentError = true
        }
      }
    }
  }

  private func isOpenWithPlace() {
    shouldShowInput = true
    inputModel.options = [.place, .date]
    onDismissInput = {
      guard inputDismissedViaDoneButton else { return }
      resultsModel = ResultsModel()
      guard let place = inputModel.place else {
        errorAlertDescription =
        "No place was selected. If the list of places was empty try fetching a place first!"
        shouldPresentError = true
        return
      }
      Task {
        switch await Self.placesClient.isPlaceOpen(place, date: inputModel.date)
        {
        case .success(let isOpen):
          resultsModel = ResultsModel(displayIsOpen: true, isOpen: isOpen)
        case .failure(let placesError):
          errorAlertDescription = placesError.localizedDescription
          shouldPresentError = true
        }
      }
    }
  }

  private func searchByText() {
    shouldShowInput = true
    inputModel.options = [
      .query, .properties, .restrictionOrBias, .placeType, .maxResults, .minRating, .isOpenNow,
      .priceLevels, .searchByTextRankPreference, .regionCode, .isStrictTypeFiltering,
    ]
    onDismissInput = {
      guard inputDismissedViaDoneButton else { return }
      resultsModel = ResultsModel()
      let properties = inputModel.useProperties ? Array(parameterConfiguration.placeProperties) : []
      let searchByTextRequest: SearchByTextRequest
      if inputModel.useRestriction {
        searchByTextRequest = SearchByTextRequest(
          textQuery: inputModel.query,
          placeProperties: properties,
          locationRestriction: inputModel.restriction,
          includedType: inputModel.placeType,
          maxResultCount: Int(inputModel.maxResults),
          minRating: inputModel.minRating,
          isOpenNow: inputModel.isOpenNow,
          priceLevels: inputModel.priceLevels,
          rankPreference: inputModel.searchByTextRankPreference,
          regionCode: inputModel.regionCode,
          isStrictTypeFiltering: inputModel.isStrictTypeFiltering)
      } else {
        searchByTextRequest = SearchByTextRequest(
          textQuery: inputModel.query,
          placeProperties: properties,
          locationBias: inputModel.bias,
          includedType: inputModel.placeType,
          maxResultCount: Int(inputModel.maxResults),
          minRating: inputModel.minRating,
          isOpenNow: inputModel.isOpenNow,
          priceLevels: inputModel.priceLevels,
          rankPreference: inputModel.searchByTextRankPreference,
          regionCode: inputModel.regionCode,
          isStrictTypeFiltering: inputModel.isStrictTypeFiltering)
      }
      Task {
        switch await Self.placesClient.searchByText(with: searchByTextRequest) {
        case .success(let places):
          resultsModel = ResultsModel(places: places)
        case .failure(let placesError):
          errorAlertDescription = placesError.localizedDescription
          shouldPresentError = true
        }
      }
    }
  }

  private func searchNearby() {
    shouldShowInput = true
    inputModel.useRestriction = true
    inputModel.options = [
      .properties, .restrictionOrBias, .maxResults, .searchNearbyRankPreference, .includedTypes,
      .excludedTypes, .includedPrimaryTypes, .excludedPrimaryTypes, .regionCode,
    ]
    onDismissInput = {
      guard inputDismissedViaDoneButton else { return }
      resultsModel = ResultsModel()
      let properties = inputModel.useProperties ? Array(parameterConfiguration.placeProperties) : []
      let searchNearbyRequest: SearchNearbyRequest
      searchNearbyRequest = SearchNearbyRequest(
        locationRestriction: inputModel.restriction,
        placeProperties: properties,
        includedTypes: ClientRequests.typesStringToSet(for: inputModel.includedTypes),
        excludedTypes: ClientRequests.typesStringToSet(for: inputModel.excludedTypes),
        includedPrimaryTypes: ClientRequests.typesStringToSet(
          for: inputModel.includedPrimaryTypes),
        excludedPrimaryTypes: ClientRequests.typesStringToSet(
          for: inputModel.excludedPrimaryTypes),
        maxResultCount: Int(inputModel.maxResults),
        rankPreference: inputModel.searchNearbyRankPreference,
        regionCode: inputModel.regionCode
      )
      Task {
        switch await Self.placesClient.searchNearby(with: searchNearbyRequest) {
        case .success(let places):
          resultsModel = ResultsModel(places: places)
        case .failure(let placesError):
          errorAlertDescription = placesError.localizedDescription
          shouldPresentError = true
        }
      }
    }
  }
}

// MARK: - Input

extension ClientRequests {
  struct InputModel {
    var options: InputModelOptions = []

    var placeID = "ChIJj61dQgK6j4AR4GeTYWZsKWw"  // Place ID for Googleplex
    var query = "Googleplex"
    var useProperties = true
    var useFilter = false
    var photo: Photo?
    var size: CGSize = CGSize(width: 1000, height: 1000)
    var date: Date = Date()
    var place: Place?
    var placeType: PlaceType?
    var maxResults: Float = 5.0
    var minRating: Float = 0.0
    var isOpenNow: Bool = true
    var priceLevels: Set<PriceLevel> = [.unspecified]
    var searchByTextRankPreference = SearchByTextRequest.RankPreference.distance
    var regionCode = ""
    var isStrictTypeFiltering: Bool = false
    var useRestriction = true
    var useRectangularRegion = false
    var restriction: any CoordinateRegionRestriction = CircularCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 100)
    var bias: any CoordinateRegionBias = CircularCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 100)
    var searchNearbyRankPreference = SearchNearbyRequest.RankPreference.popularity
    var includedTypes = ""
    var excludedTypes = ""
    var includedPrimaryTypes = ""
    var excludedPrimaryTypes = ""

    struct InputModelOptions: OptionSet {
      let rawValue: UInt

      static let placeID = InputModelOptions(rawValue: 1 << 0)
      static let query = InputModelOptions(rawValue: 1 << 1)
      static let properties = InputModelOptions(rawValue: 1 << 2)
      static let filter = InputModelOptions(rawValue: 1 << 3)
      static let photo = InputModelOptions(rawValue: 1 << 4)
      static let size = InputModelOptions(rawValue: 1 << 5)
      static let date = InputModelOptions(rawValue: 1 << 6)
      static let place = InputModelOptions(rawValue: 1 << 7)
      static let placeType = InputModelOptions(rawValue: 1 << 8)
      static let maxResults = InputModelOptions(rawValue: 1 << 9)
      static let minRating = InputModelOptions(rawValue: 1 << 10)
      static let isOpenNow = InputModelOptions(rawValue: 1 << 11)
      static let priceLevels = InputModelOptions(rawValue: 1 << 12)
      static let searchByTextRankPreference = InputModelOptions(rawValue: 1 << 13)
      static let regionCode = InputModelOptions(rawValue: 1 << 14)
      static let isStrictTypeFiltering = InputModelOptions(rawValue: 1 << 15)
      static let restrictionOrBias = InputModelOptions(rawValue: 1 << 16)
      static let searchNearbyRankPreference = InputModelOptions(rawValue: 1 << 17)
      static let includedTypes = InputModelOptions(rawValue: 1 << 18)
      static let excludedTypes = InputModelOptions(rawValue: 1 << 19)
      static let includedPrimaryTypes = InputModelOptions(rawValue: 1 << 20)
      static let excludedPrimaryTypes = InputModelOptions(rawValue: 1 << 21)
    }
  }
}

extension ClientRequests {
  struct Input: View {
    @Binding var inputModel: InputModel
    @Binding var shouldShowInput: Bool
    @Binding var inputDismissedViaDoneButton: Bool

    private let placeTypes: [PlaceType] = [.carDealer, .library, .bowlingAlley, .bank, .church]

    var body: some View {
      NavigationView {
        Form {
          SwiftUI.Section {
            if inputModel.options.contains(.placeID) {
              TextField("Place ID", text: $inputModel.placeID)
            }
            if inputModel.options.contains(.place) { placePicker }
            if inputModel.options.contains(.query) {
              TextField("Query", text: $inputModel.query)
            }
            if inputModel.options.contains(.properties) {
              Toggle("Use configured properties", isOn: $inputModel.useProperties)
            }
            if inputModel.options.contains(.filter) {
              Toggle("Use configured filter", isOn: $inputModel.useFilter)
            }
            if inputModel.options.contains(.photo) { photoPicker }
            if inputModel.options.contains(.size) { sizeView }
            if inputModel.options.contains(.date) {
              DatePicker(
                "Is open at",
                selection: $inputModel.date,
                displayedComponents: [.date, .hourAndMinute]
              )
            }
          }
          SwiftUI.Section {
            if inputModel.options.contains(.placeType) { placeTypePicker }
            if inputModel.options.contains(.maxResults) { maxResultsView }
            if inputModel.options.contains(.minRating) { minRatingView }
            if inputModel.options.contains(.isOpenNow) { isOpenNowView }
            if inputModel.options.contains(.priceLevels) { priceLevelPicker }
            if inputModel.options.contains(.searchByTextRankPreference) {
              searchByTextRankPreferencePicker
            }
            if inputModel.options.contains(.searchNearbyRankPreference) {
              searchNearbyRankPreferencePicker
            }
            if inputModel.options.contains(.regionCode) {
              TextField("Region Code", text: $inputModel.regionCode)
            }
            if inputModel.options.contains(.isStrictTypeFiltering) { isStrictTypeFilteringPicker }
          }
          SwiftUI.Section {
            if inputModel.options.contains(.includedTypes) {
              TextField("Included Types", text: $inputModel.includedTypes)
            }
            if inputModel.options.contains(.excludedTypes) {
              TextField("Excluded Types", text: $inputModel.excludedTypes)
            }
            if inputModel.options.contains(.includedPrimaryTypes) {
              TextField("Included Primary Types", text: $inputModel.includedPrimaryTypes)
            }
            if inputModel.options.contains(.excludedPrimaryTypes) {
              TextField("Excluded Primary Types", text: $inputModel.excludedPrimaryTypes)
            }
          }
          SwiftUI.Section {
            if inputModel.options.contains(.restrictionOrBias) { useRestrictionPicker }
          }
          SwiftUI.Section {
            Button("Done") {
              shouldShowInput = false
              inputDismissedViaDoneButton = true
            }
          }
        }
      }
      .onAppear() {
        inputDismissedViaDoneButton = false
      }
    }

    private var placePicker: some View {
      Picker("Place", selection: $inputModel.place) {
        ForEach(ClientRequests.places, id: \.self) { place in
          Text("\(place.displayName ?? place.placeID ?? "unknown")")
            .tag(Optional(place))
        }
        .onAppear {
          inputModel.place = ClientRequests.places[0]
        }
      }
    }

    private var photoPicker: some View {
      Picker("Photo", selection: $inputModel.photo) {
        ForEach(ClientRequests.photos, id: \.self) { photo in
          Text(photo.attributions ?? AttributedString("\(photo.maxSize)")).tag(Optional(photo))
        }
        .onAppear {
          inputModel.photo = ClientRequests.photos[0]
        }
      }
    }

    @ViewBuilder
    private var sizeView: some View {
      VStack {
        Slider(value: $inputModel.size.width, in: 100...4800, step: 100) {
          EmptyView()
        } minimumValueLabel: {
          Text("100")
        } maximumValueLabel: {
          Text("4800")
        }
        Text("Max Size Width: \(Int(inputModel.size.width)) px")
      }
      VStack {
        Slider(value: $inputModel.size.height, in: 100...4800, step: 100) {
          EmptyView()
        } minimumValueLabel: {
          Text("100")
        } maximumValueLabel: {
          Text("4800")
        }
        Text("Max Size Height: \(Int(inputModel.size.height)) px")
      }
    }

    private var placeTypePicker: some View {
      Picker("Place Type", selection: $inputModel.placeType) {
        Text("None").tag(PlaceType?.none)
        ForEach(placeTypes, id: \.self) { placeType in
          Text(placeType.rawValue).tag(Optional(placeType))
        }
      }
    }

    private var maxResultsView: some View {
      VStack {
        Slider(value: $inputModel.maxResults, in: 1...20, step: 1) {
          EmptyView()
        } minimumValueLabel: {
          Text("1")
        } maximumValueLabel: {
          Text("20")
        }
        Text("Max Results: \(Int(inputModel.maxResults))")
      }
    }

    private var minRatingView: some View {
      VStack {
        Slider(value: $inputModel.minRating, in: 0...5, step: 0.5) {
          EmptyView()
        } minimumValueLabel: {
          Text("0.0")
        } maximumValueLabel: {
          Text("5.0")
        }
        Text("Min Rating: \(inputModel.minRating)")
      }
    }

    private var isOpenNowView: some View {
      Picker("Is Open Now", selection: $inputModel.isOpenNow) {
        Text("No").tag(Optional(false))
        Text("Yes").tag(Optional(true))
      }
    }

    private var priceLevelPicker: some View {
      MultiPicker<Text, PriceLevel>(
        label: Text("Price Levels"),
        options: PriceLevel.allCases,
        optionFormatter: { $0.description },
        selectedOptions: $inputModel.priceLevels
      )
    }

    private var searchByTextRankPreferencePicker: some View {
      Picker("Rank Preference:", selection: $inputModel.searchNearbyRankPreference) {
        ForEach(SearchByTextRequest.RankPreference.allCases, id: \.self) {
          rankPreference in
          Text("\(String(describing: rankPreference))").tag(Optional(rankPreference))
        }
      }
    }

    private var isStrictTypeFilteringPicker: some View {
      Picker("Is Strict Type Filtering", selection: $inputModel.isStrictTypeFiltering) {
        Text("No").tag(Optional(false))
        Text("Yes").tag(Optional(true))
      }
    }

    private var searchNearbyRankPreferencePicker: some View {
      Picker("Rank Preference:", selection: $inputModel.searchNearbyRankPreference) {
        ForEach(SearchNearbyRequest.RankPreference.allCases, id: \.self) {
          rankPreference in
          Text("\(String(describing: rankPreference))").tag(Optional(rankPreference))
        }
      }
    }

    @ViewBuilder
    private var useRestrictionPicker: some View {
      Picker("Use Restriction or Bias CoordinateRegion", selection: $inputModel.useRestriction) {
        Text("Restriction").tag(true)
        Text("Bias").tag(false)
      }
      Picker("CoordinateRegion Type", selection: $inputModel.useRectangularRegion) {
        Text("Rectangular").tag(true)
        Text("Circular").tag(false)
      }
      CoordinateRegionInput(
        useRestriction: inputModel.useRestriction,
        useRectangularRegion: $inputModel.useRectangularRegion,
        restriction: $inputModel.restriction,
        bias: $inputModel.bias)
    }
  }

  struct CoordinateRegionInput: View {
    var useRestriction: Bool
    @Binding var useRectangularRegion: Bool
    @Binding var restriction: any CoordinateRegionRestriction
    @Binding var bias: any CoordinateRegionBias

    @State private var northEastLatInput = ""
    @State private var northEastLongInput = ""
    @State private var southWestLatInput = ""
    @State private var southWestLongInput = ""
    @State private var centerLatInput = ""
    @State private var centerLongInput = ""
    @State private var radiusInput = ""

    @State var shouldShowInputAlert = false
    @State var inputAlertDescription = ""

    var body: some View {
      if useRectangularRegion {
        rectangularCoordinateRegionInput
          .alert(isPresented: $shouldShowInputAlert) {
            Alert(
              title: Text("Input Problem"),
              message: Text(inputAlertDescription)
            )
          }
      } else {
        circularCoordinateRegionInput
      }
    }

    @ViewBuilder
    private var rectangularCoordinateRegionInput: some View {
      HStack {
        Text("NE")
        TextField("Latitude", text: $northEastLatInput).keyboardType(.numbersAndPunctuation)
        TextField("Longitude", text: $northEastLongInput).keyboardType(.numbersAndPunctuation)
      }
      .onChange(of: northEastLatInput) { value in updateCoordinateRegion() }
      .onChange(of: northEastLongInput) { value in updateCoordinateRegion() }
      HStack {
        Text("SW")
        TextField("Latitude", text: $southWestLatInput).keyboardType(.numbersAndPunctuation)
        TextField("Longitude", text: $southWestLongInput).keyboardType(.numbersAndPunctuation)
      }
      .onChange(of: southWestLatInput) { value in updateCoordinateRegion() }
      .onChange(of: southWestLongInput) { value in updateCoordinateRegion() }
      .onAppear {
        if let currentRectangularCoordinateRegion = (useRestriction ? restriction : bias)
            as? RectangularCoordinateRegion
        {
          northEastLatInput = "\(currentRectangularCoordinateRegion.northEast.latitude)"
          northEastLongInput = "\(currentRectangularCoordinateRegion.northEast.longitude)"
          southWestLatInput = "\(currentRectangularCoordinateRegion.southWest.latitude)"
          southWestLongInput = "\(currentRectangularCoordinateRegion.southWest.longitude)"
        }
      }
    }

    @ViewBuilder
    private var circularCoordinateRegionInput: some View {
      HStack {
        Text("Center")
        TextField("Latitude", text: $centerLatInput).keyboardType(.numbersAndPunctuation)
        TextField("Longitude", text: $centerLongInput).keyboardType(.numbersAndPunctuation)
      }
      .onChange(of: centerLatInput) { value in updateCoordinateRegion() }
      .onChange(of: centerLongInput) { value in updateCoordinateRegion() }
      HStack {
        Text("Radius")
        TextField("Meters", text: $radiusInput).keyboardType(.numbersAndPunctuation)
      }
      .onChange(of: radiusInput) { value in updateCoordinateRegion() }
      .onAppear {
        if let currentCircularCoordinateRegion = bias as? CircularCoordinateRegion {
          centerLatInput = "\(currentCircularCoordinateRegion.center.latitude)"
          centerLongInput = "\(currentCircularCoordinateRegion.center.longitude)"
          radiusInput = "\(currentCircularCoordinateRegion.radius)"
        }
      }
    }

    private func updateCoordinateRegion() {
      if useRectangularRegion,
         let northEastLat = Double(northEastLatInput),
         let northEastLong = Double(northEastLongInput),
         let southWestLat = Double(southWestLatInput),
         let southWestLong = Double(southWestLongInput)
      {
        let rectangularCoordinateRegion = RectangularCoordinateRegion(
          northEast: CLLocationCoordinate2D(latitude: northEastLat, longitude: northEastLong),
          southWest: CLLocationCoordinate2D(latitude: southWestLat, longitude: southWestLong))
        guard let rectangularCoordinateRegion else {
          inputAlertDescription =
          "The given coordinates do not represent a valid rectangular coordinate region."
          shouldShowInputAlert = true
          return
        }
        if useRestriction {
          restriction = rectangularCoordinateRegion
        } else {
          bias = rectangularCoordinateRegion
        }
      } else if let centerLat = Double(centerLatInput),
                let centerLong = Double(centerLongInput),
                let radius = Double(radiusInput)
      {
        let circularCoordinateRegion = CircularCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong),
          radius: radius)
        if useRestriction {
          restriction = circularCoordinateRegion
        } else {
          bias = circularCoordinateRegion
        }
      }
    }
  }
}

// MARK: - Results

extension ClientRequests {
  struct ResultsModel: Equatable {
    var place: Place? {
      didSet {
        guard let place else { return }
        ClientRequests.places.append(place)
        guard let photos = place.photos else { return }
        ClientRequests.photos.append(contentsOf: photos)
      }
    }
    var image: Image?
    var suggestions: [AutocompleteSuggestion]?
    var displayIsOpen = false
    var isOpen: Bool?
    var places: [Place]? {
      didSet {
        guard let places else { return }
        ClientRequests.places.append(contentsOf: places)
        for place in places {
          guard let photos = place.photos else { return }
          ClientRequests.photos.append(contentsOf: photos)
        }
      }
    }
  }
}

extension ClientRequests {
  struct Results: View {
    @Binding var resultsModel: ResultsModel

    var body: some View {
      if resultsModel == ResultsModel() {
        Text("No Results.")
      } else {
        if let place = resultsModel.place { PlaceView(place: place) }
        if let image = resultsModel.image { image }
        if let suggestions = resultsModel.suggestions {
          AutocompleteSuggestionsView(suggestions: suggestions)
        }
        if resultsModel.displayIsOpen {
          Text("Place open status is \(displayText(for: resultsModel.isOpen)).")
        }
        if let places = resultsModel.places {
          if !places.isEmpty {
            List {
              ForEach(places, id: \.self) { place in
                NavigationLink(
                """
                Name: \(place.displayName ?? "")
                Place ID: \(place.placeID ?? "")
                """
                ) {
                  PlaceView(place: place)
                }
                .minimumScaleFactor(0.5)
                .lineLimit(2)
              }
            }
          } else {
            Text("No Places Found.")
          }
        }
      }
    }
  }

  struct PlaceView: View {
    var place: Place

    var body: some View {
      List {
        Text("Name: \(place.displayName ?? "")")
        Text("Place ID: \(place.placeID ?? "")")
          .minimumScaleFactor(0.5)
          .lineLimit(1)
        Text("Full Description:\n\(place.description)")
      }
      .enableTextSelectionIfAvailable()
    }
  }

  struct AutocompleteSuggestionsView: View {
    var suggestions: [AutocompleteSuggestion]

    var body: some View {
      List {
        ForEach(suggestions, id: \.hashValue) { suggestion in
          switch suggestion {
          case .place(let placeSuggestion):
            VStack(alignment: .leading) {
              Text("Place ID: \(placeSuggestion.placeID)")
                .minimumScaleFactor(0.5)
                .lineLimit(1)
              Text("Types: \(placeSuggestion.types.description)")
              Text("Distance: \(placeSuggestion.distance?.description ?? "unknown")")
              Text("\(boldedAutocompleteMatch(for: placeSuggestion.attributedFullText))")
            }
          @unknown default:
            Text("Unknown autocomplete suggestion.")
          }
        }
      }
      .enableTextSelectionIfAvailable()
    }

    func boldedAutocompleteMatch(for text: AttributedString?) -> AttributedString {
      guard let text else { return "" }
      let boldFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
      var bolded: AttributedString = text

      guard
        let sourceAttributes = try? AttributeContainer(
          [.autocompleteMatch: ""],
          including: \.googlePlaces)
      else { return "" }
      let finalAttributes = sourceAttributes.merging(AttributeContainer([.font: boldFont]))
      bolded.replaceAttributes(sourceAttributes, with: finalAttributes)

      return bolded
    }
  }
}

// MARK: - Display helpers

extension ClientRequests {
  static func displayText(for boolean: Bool?) -> String {
    guard let boolean else { return "unknown" }
    return "\(boolean)"
  }

  static func typesStringToSet(for string: String?) -> Set<PlaceType>? {
    guard let string = string else {
      return nil
    }

    var typesSet = Set<PlaceType>()
    let trimmedComponents =
    string
      .components(separatedBy: ",")
      .map { $0.lowercased() }
      .filter { !$0.isEmpty }
    for component in trimmedComponents {
      typesSet.insert(PlaceType(rawValue: component))
    }
    return typesSet
  }
}

// MARK: - Test Data

extension ClientRequests {
  static var places = [Place]()
  static var photos = [Photo]()
}

// MARK: - Misc Extensions

struct TextSelectableModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .textSelection(.enabled)
  }
}

extension View {
  @ViewBuilder
  func enableTextSelectionIfAvailable() -> some View {
    self
      .modifier(TextSelectableModifier())
  }
}

extension PriceLevel: CustomStringConvertible {
  public var description: String {
    switch self {
    case .unspecified:
      return "unspecified"
    case .free:
      return "free"
    case .inexpensive:
      return "inexpensive"
    case .moderate:
      return "moderate"
    case .expensive:
      return "expensive"
    case .veryExpensive:
      return "veryExpensive"
    @unknown default:
      assertionFailure("There is an unimplemented case.")
      return ""
    }
  }
}

extension PlaceType: CustomStringConvertible {
  public var description: String {
    return self.rawValue
  }
}

extension SearchByTextRequest.RankPreference: CustomStringConvertible {
  public var description: String {
    switch self {
    case .distance:
      return "distance"
    case .relevance:
      return "relevance"
    @unknown default:
      assertionFailure("There is an unimplemented case.")
      return ""
    }
  }
}

extension SearchNearbyRequest.RankPreference: CustomStringConvertible {
  public var description: String {
    switch self {
    case .popularity:
      return "popularity"
    case .distance:
      return "distance"
    @unknown default:
      assertionFailure("There is an unimplemented case.")
      return ""
    }
  }
}
