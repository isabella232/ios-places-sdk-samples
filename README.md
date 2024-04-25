GooglePlacesDemos contains a demo application showcasing various features of
the GooglePlacesSwift SDK for iOS.

Before starting, please note that these demos are directed towards a technical
audience. You'll also need Xcode 15.0 or later, with the iOS SDK 15.0 or later.

If you're new to the API, please read the Introduction section of the Google
Places API for iOS documentation-
  https://developers.google.com/places/ios-api/

Once you've read the Introduction page, follow the first couple of steps on the
"Getting Started" page. Specifically;

  * Obtain an API key for the demo application, and specify the bundle ID of
    this demo application as an an 'allowed iOS app'. By default, the bundle ID
    is "com.example.GooglePlacesDemos".

  * Create a configuration file for your API key. By default the file should be
    named "GooglePlacesDemos.xcconfig" and be located at the same directory
    level as the demo application's "Info.plist" file. The contents of this file
    should contain at least a line like "API_KEY = <insert your API key here>".
    This should be enough for the demo app to retrieve your key to use for
    requests. (See https://help.apple.com/xcode/#/dev745c5c974 for more
    information about xcconfig files.)
