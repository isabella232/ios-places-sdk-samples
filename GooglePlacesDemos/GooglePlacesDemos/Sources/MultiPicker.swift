import SwiftUI

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
        Text(ListFormatter.localizedString(byJoining: selectedOptions.map { optionFormatter($0) }))
          .foregroundColor(.gray)
          .multilineTextAlignment(.trailing)
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
          }.tag(option.id)
        }
      }.listStyle(GroupedListStyle())
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
