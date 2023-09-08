# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2023-09-08

### Added

- (#53) Add a configuration option for the unhealthy status code - thanks @floere!

### Removed

- **Breaking:** Dropped support for Ruby versions < 2.7.0

## [0.2.0] - 2022-02-21

### Added

- The `static` check, which uses the provided check parameters to return the same result every time.

### Changed

- **Breaking**: The Redis check now requires being configured with an instance of the Redis client, via the named `instance` parameter
- **Deprecated**: The `git_revision` check will be removed in rack-ecg version 1.0.0. For a suggested replacement, [see the GitRevision Check Replacement example](./examples/gitrevision_check_replacement.ru), which uses the `static` check to memoize the value.

### Removed

- **Breaking:** Dropped support for Ruby versions < 2.6.0

## [0.1.0] - 2020-12-16

### Added

- YARD-based gem documentation

### Changed

- **Breaking**: The Rack::ECG initializer now uses named options, instead of an options hash.

  If you manually initialized an instance, you may need to use the `**` operator to pass these options. (e.g. `Rack::ECG.new(nil, **options)`)

### Removed

- **Breaking:** Dropped support for Ruby versions < 2.5.0

## [0.0.5] - 2017-05-12

### Added

- A new `sequel` check (#8), which checks if the Sequel database connection is active.

## [0.0.4] - 2017-05-04

### Added

- A new `active_record` check (#7), which checks if the ActiveRecord connection is active.
- A new `redis` check (#7), which checks if the Redis connection is active.

## [0.0.3] - 2017-02-13

### Added

- Accept a `hook` in configuration, which is run when all check results have been gathered (#6)

### Fixed

- Resolved an issue with the migration version check and MySQL connections (#3)

## [0.0.2] - 2015-06-17

### Added

- Support running Rack::ECG as a standalone application
- Support adding checks via the `CheckRegistry`

## [0.0.1] - 2015-04-09

### Added

- Base middleware to use in Rails or Rack apps
- `git_revision` check to return the current git revision
- `migration_version` check to return the current ActiveRecord migration version

[Unreleased]: https://github.com/envato/rack-ecg/compare/v0.3.0...HEAD
[0.3.0]:      https://github.com/envato/rack-ecg/compare/v0.2.0...v0.3.0
[0.2.0]:      https://github.com/envato/rack-ecg/compare/v0.1.0...v0.2.0
[0.1.0]:      https://github.com/envato/rack-ecg/compare/v0.0.5...v0.1.0
[0.0.5]:      https://github.com/envato/rack-ecg/compare/v0.0.4...v0.0.5
[0.0.4]:      https://github.com/envato/rack-ecg/compare/v0.0.3...v0.0.4
[0.0.3]:      https://github.com/envato/rack-ecg/compare/v0.0.2...v0.0.3
[0.0.2]:      https://github.com/envato/rack-ecg/compare/v0.0.1...v0.0.2
[0.0.1]:      https://github.com/envato/rack-ecg/releases/tag/v0.0.1
