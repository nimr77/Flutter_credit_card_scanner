## 0.13.0

### Added

- Swift Package Manager support for iOS (the CocoaPods podspec is kept)

### Changed

- Android text recognition now calls ML Kit natively; ML Kit is no longer compiled into iOS builds
- Android frames are sent to ML Kit as NV21
- iOS minimum deployment target is 15.5 in the example app

### Removed

- `google_mlkit_text_recognition` (and transitively `google_mlkit_commons`) Dart dependency

## 0.12.1

### Changed

- Updated `apple_vision_recognize_text` to ^0.1.0
- Updated `camera` to ^0.12.1
- Updated `google_mlkit_text_recognition` to ^0.17.1
- Updated example app dependencies (`firebase_core` ^5.0.0, `cupertino_icons` ^2.0.0)
- Refreshed transitive dependencies

## 0.11.0

### Added

- Debug options
- Adding credit card validation
- More config by the developer

### Changed

- Updated the plugin to use the latest version of the Google ML Kit library
- Enhanced the proformance

## 0.10.0

### Added

- Using apple vision text recognition for ios

## 0.9.0

### Changed

- Updated the plugin to use the latest version of the Google ML Kit library
- Update the scanning UI to use the latest design guidelines
- Faster scanning speed

## 0.8.0

### Changed

- Updated the plugin to use the latest version of the Google ML Kit library

## 0.7.3

### Added

- More documentation for existing features
- Improved usage instructions in README

### Changed

- Enhanced code comments for better understanding

### Fixed

- N/A

### Deprecated

- N/A

### Removed

- N/A

### Security

- N/A

## 0.0.1

### Added

- Initial release of the plugin
- Basic functionality for credit card scanning by camera using google ML

### Changed

- N/A

### Fixed

- N/A

### Deprecated

- N/A

### Removed

- N/A

### Security

- N/A
