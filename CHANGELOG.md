# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-04-09

### Added
- `file_sha1` for streaming SHA-1 file checksums
- `file_crc32` for streaming CRC32 file checksums
- `digest(string, algo:, format:)` generic string checksum dispatch
- `file_digest(path, algo:, format:)` generic file checksum dispatch

### Fixed
- `compare_files` now works with all algorithms including `:sha1` and `:crc32` (previously raised `NoMethodError`)

## [0.3.0] - 2026-04-04

### Added
- `compare_files` method to check if two files have the same checksum

## [0.2.0] - 2026-04-03

### Added
- HMAC-SHA256 and HMAC-SHA512 via `hmac_sha256` and `hmac_sha512`
- `file_sha512` for SHA-512 file hashing
- `files` method for hashing multiple files in one call
- `verify_hmac?` for timing-safe HMAC verification

## [0.1.6] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.5] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.4] - 2026-03-26

### Fixed
- Add Sponsor badge to README
- Fix license section link format

## [0.1.3] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements
- Remove inline comments from Development section to match template

## [0.1.2] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes

## [0.1.1] - 2026-03-22

### Changed
- Improve source code, tests, and rubocop compliance

## [0.1.0] - 2026-03-21

### Added
- Initial release
- MD5, SHA-1, SHA-256, SHA-512, and CRC32 checksums for strings
- Streaming file checksums (MD5, SHA-256) in 8KB chunks for constant memory usage
- Multi-algorithm single-pass file checksum computation
- File checksum verification with timing-safe comparison
- Hex and Base64 output format support

[0.4.0]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.4.0
[0.3.0]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.3.0
[0.2.0]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.2.0
[0.1.6]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.1.6
[0.1.5]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.1.5
[0.1.4]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.1.4
[0.1.3]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.1.3
[0.1.2]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.1.2
[0.1.1]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.1.1
[0.1.0]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.1.0
