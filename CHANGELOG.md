# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.0] - 2026-04-15

### Added
- `sha384(string, format:)` for SHA-384 string digests
- `file_sha384(path, format:)` for streaming SHA-384 file checksums
- `:sha384` now supported by the `digest` / `file_digest` / `file_multi` / `files` / `verify_string?` / `verify?` / `compare_files` / `directory_checksum` dispatchers (via `ALGORITHMS`)
- `hmac_sha384(string, key:, format:)` via `HMAC_ALGORITHMS`; `file_hmac` and `verify_hmac?` now also accept `algo: :sha384`

## [0.6.0] - 2026-04-15

### Added
- `hmac_sha1(string, key:, format:)` for HMAC-SHA1 string digests
- `file_hmac(path, key:, algo:, format:)` for streaming HMAC digests over file contents (supports `:sha1`, `:sha256`, `:sha512`)
- `verify_string?(string, expected, algo:, format:)` for timing-safe verification of a string checksum

### Changed
- `verify_hmac?` now also accepts `algo: :sha1`

## [0.5.0] - 2026-04-09

### Added
- `directory_checksum(path, algo:, format:)` for computing a combined checksum of all files in a directory
- `files` method now supports `:crc32` algorithm

### Fixed
- `files` method raised `Error` when using `:crc32` algorithm (now dispatches via `file_digest`)

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

[Unreleased]: https://github.com/philiprehberger/rb-checksum/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/philiprehberger/rb-checksum/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/philiprehberger/rb-checksum/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/philiprehberger/rb-checksum/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/philiprehberger/rb-checksum/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/philiprehberger/rb-checksum/compare/v0.1.6...v0.2.0
[0.1.6]: https://github.com/philiprehberger/rb-checksum/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/philiprehberger/rb-checksum/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/philiprehberger/rb-checksum/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/philiprehberger/rb-checksum/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/philiprehberger/rb-checksum/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/philiprehberger/rb-checksum/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/philiprehberger/rb-checksum/releases/tag/v0.1.0
