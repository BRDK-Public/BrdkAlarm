# 📋 Changelog

All notable changes to `BrdkAlarm` will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and `BrdkAlarm` adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2]

### Added
- NameInConfig input to be able to differentiate instance and config name. Useful with indexed PackML modules when using {1} in alarm configurations.
- Alarm query for testing in sample code.

### Changed
- Renamed mpLinks in sample code to start with mp instead of g.
- Disable MpComConfigBasic_0 after usage.

### Fixed
- Error output on empty Name input (unless AlarmConfig.Name is being used)
- Stuck when missing MpLinkList at initial Enable.


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

## [unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security