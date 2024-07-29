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

/// The main list of samples for the demo app.
struct SampleList: View {
  let sampleSections = Samples.allSampleSections()

  @StateObject var configuration = ParameterConfiguration()

  var body: some View {
    NavigationView {
      List(sampleSections, id: \.self) { section in
        Section {
          ForEach(section.samples, id: \.self) { sample in
            NavigationLink(sample.title) {
              switch sample.viewType {
              case .swiftUI(let view):
                AnyView(erasing: view.parameterConfiguration(configuration))
              case .uiKit(let viewControllerType):
                SampleWrapperViewController(viewControllerType: viewControllerType)
              }
            }
          }
        } header: {
          Text(section.name).textCase(.none)
        }
      }
      .toolbar {
        NavigationLink("Configure") {
          ConfigurationView(configuration: configuration)
        }
      }
    }
  }

  struct SampleWrapperViewController: UIViewControllerRepresentable {
    var viewControllerType: UIViewController.Type

    func makeUIViewController(context: Context) -> some UIViewController {
      return viewControllerType.init()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
  }
}

struct ParameterConfigurationKey: EnvironmentKey {
  static let defaultValue = ParameterConfiguration()
}

extension EnvironmentValues {
  var parameterConfiguration: ParameterConfiguration {
    get { self[ParameterConfigurationKey.self] }
    set { self[ParameterConfigurationKey.self] = newValue }
  }
}

extension View {
  func parameterConfiguration(_ configuration: ParameterConfiguration) -> some View {
    environment(\.parameterConfiguration, configuration)
  }
}

#Preview {
  SampleList()
}
