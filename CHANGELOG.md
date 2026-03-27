# 📋 Changelog

All notable changes to `BrdkAlarm` will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and `BrdkAlarm` adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1]

### Added
- Updated README.md with library description, usage instructions, dependencies, and BrdkPackML integration example

### Changed
- Updated comments in BrdkAlarm.fun and Types.typ to match the implementation

### Removed
- Removed unused `AlarmState` output (was declared but never assigned)

### Fixed
- Fixed edge detection for `Acknowledge` and `Confirm` inputs — `acknowledgeOld`/`confirmOld` are now updated every scan cycle instead of only during the exit phase.


## [1.0.0]

### Added
New Release of BrdkAlarm, with documentation attached in /help folder
### Changed

### Deprecated

### Removed

### Fixed

### Security
