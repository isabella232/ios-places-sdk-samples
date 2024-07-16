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

/// A view that allows selecting multiple options from a list.
struct MultiPicker<Label: View, Option: Identifiable & Hashable>: View {
  let label: Label
  let options: [Option]
  let optionFormatter: (Option) -> String

  @Binding var selectedOptions: Set<Option>

  var body: some View {
    NavigationLink(destination: optionSelectionView()) {
      HStack {
        label.foregroundColor(.black)
        Spacer()
        Text(ListFormatter.localizedString(byJoining: selectedOptions.map { optionFormatter($0) }.sorted()))
          .foregroundColor(.gray)
          .multilineTextAlignment(.trailing)
          .truncationMode(.tail)
          .lineLimit(20)
      }
    }
  }

  private func optionSelectionView() -> some View {
    OptionSelectionView(
      options: options,
      optionFormatter: optionFormatter,
      selectedOptions: $selectedOptions
    )
  }

  /// Displays a list of options and allows selecting multiple options.
  struct OptionSelectionView: View {
    let options: [Option]
    let optionFormatter: (Option) -> String

    @Binding var selectedOptions: Set<Option>

    var body: some View {
      List {
        ForEach(options) { option in
          Button(action: { toggleSelection(option: option) }) {
            HStack {
              Text(optionFormatter(option)).foregroundColor(.black)
              Spacer()
              if selectedOptions.contains(where: { $0.id == option.id }) {
                Image(systemName: "checkmark").foregroundColor(.accentColor)
              }
            }
          }
        }
      }
      .listStyle(GroupedListStyle())
      .toolbar {
        Button("Select All") {
          selectedOptions.formUnion(options)
        }
        Button("Deselect All") {
          selectedOptions = Set<Option>()
        }
      }
    }

    private func toggleSelection(option: Option) {
      if let existingIndex = selectedOptions.firstIndex(where: { $0.id == option.id }) {
        selectedOptions.remove(at: existingIndex)
      } else {
        selectedOptions.insert(option)
      }
    }
  }
}

#Preview {
  struct MultiPickerPreviewContainer: View {
    @State private var selectedValues = Set<Int>()

    var body: some View {
      NavigationView {
        MultiPicker<Text, Int>(
          label: Text("Test Picker"),
          options: [1, 2, 3],
          optionFormatter: { "Option \($0)" },
          selectedOptions: $selectedValues
        )
      }
    }
  }

  return MultiPickerPreviewContainer()
}

extension Int: Identifiable {
  public var id: Self { self }
}
