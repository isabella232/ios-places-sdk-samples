# New README Template

## Description

GooglePlacesDemos contains a demo application showcasing various features of
the GooglePlacesSwift SDK for iOS.

## Requirements

Before starting, please note that these demos are directed towards a technical
audience. You'll also need Xcode 15.0 or later, with the iOS SDK 15.0 or later.

If you're new to the API, please read the Introduction section of the Google
Places API for iOS documentation - https://developers.google.com/places/ios-api/

## Installation

Once you've read the Introduction page, follow the first couple of steps on the
"Getting Started" page. Specifically;

  * Obtain an API key for the demo application, and specify the bundle ID of
    this demo application as an an 'allowed iOS app'. By default, the bundle ID
    is "com.example.GooglePlacesDemos".

  * Create a configuration file for your API key. By default the file should be
    named "GooglePlacesDemos.xcconfig" and be located at the same directory
    level as the demo application's "Info.plist" file. The contents of this file
    should contain at least a line like `API_KEY = <insert your API key here>`.
    This should be enough for the demo app to retrieve your key to use for
    requests. (See https://help.apple.com/xcode/#/dev745c5c974 for more
    information about xcconfig files.)

## Documentation

https://developers.google.com/places/ios-api/

## Usage

### Sample List

A list of samples is presented at app startup. These samples each demonstrate a
specific capability or capabilities of the SDK. The "Samples" directory contains
most of the actual sample code. Everything else - with the exception of
ParameterConfiguration.swift - is just scaffolding for the sample app to enable easy
display of various samples.

### ParameterConfiguration.swift

The "Configure" button on the startup page allows setting place properties and
autocomplete filter options that allows easy configuration that can apply to
multiple samples. These options are set in ParameterConfiguration.swift which
can be used as a reference for using `PlaceType` and `AutocompleteFilter`.

## Contributing

Please see CONTRIBUTING.md

## Terms of Service

This library uses Google Maps Platform services, and any use of Google Maps
Platform is subject to the [Terms of Service](https://cloud.google.com/maps-platform/terms).

For clarity, this library, and each underlying component, is not a Google Maps
Platform Core Service.

## Support

This library is offered via an open source license. It is not governed by the
Google Maps Platform Support
[Technical Support Services Guidelines](https://cloud.google.com/maps-platform/terms/tssg),
the [SLA](https://cloud.google.com/maps-platform/terms/sla), or the
[Deprecation Policy](https://cloud.google.com/maps-platform/terms) (however,
any Google Maps Platform services used by the library remain subject to the
Google Maps Platform Terms of Service).

This library adheres to [semantic versioning](https://semver.org/) to indicate
when backwards-incompatible changes are introduced. Accordingly, while the
library is in version 0.x, backwards-incompatible changes may be introduced at
any time. 

If you find a bug, or have a feature request, please [file an issue]() on
GitHub. If you would like to get answers to technical questions from other
Google Maps Platform developers, ask through one of our
[developer community channels](https://developers.google.com/maps/developer-community).
If you'd like to contribute, please check the [Contributing guide]().

You can also discuss this library on our [Discord server](https://discord.gg/hYsWbmk).
   
