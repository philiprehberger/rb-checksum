# philiprehberger-checksum

[![Tests](https://github.com/philiprehberger/rb-checksum/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-checksum/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-checksum.svg)](https://rubygems.org/gems/philiprehberger-checksum)
[![License](https://img.shields.io/github/license/philiprehberger/rb-checksum)](LICENSE)

Simple file and string checksums with streaming support for large files

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem 'philiprehberger-checksum'
```

Or install directly:

```bash
gem install philiprehberger-checksum
```

## Usage

```ruby
require 'philiprehberger/checksum'

Philiprehberger::Checksum.sha256('hello')  # => "2cf24dba5fb0a30e..."
```

### String Checksums

```ruby
Philiprehberger::Checksum.md5('hello')     # => "5d41402abc4b2a76..."
Philiprehberger::Checksum.sha1('hello')    # => "aaf4c61ddcc5e8a2..."
Philiprehberger::Checksum.sha256('hello')  # => "2cf24dba5fb0a30e..."
Philiprehberger::Checksum.sha512('hello')  # => "9b71d224bd62f378..."
Philiprehberger::Checksum.crc32('hello')   # => "3610a686"
```

### File Checksums

File checksums use streaming reads in 8KB chunks for constant memory usage:

```ruby
Philiprehberger::Checksum.file_md5('/path/to/file')
Philiprehberger::Checksum.file_sha256('/path/to/file')
```

### Multi-Algorithm

Compute multiple checksums in a single read pass:

```ruby
result = Philiprehberger::Checksum.file_multi('/path/to/file', :md5, :sha256)
# => { md5: "...", sha256: "..." }
```

### Verification

Verify a file against expected checksums with timing-safe comparison:

```ruby
Philiprehberger::Checksum.verify?('/path/to/file', sha256: 'expected_hex')
# => true or false
```

### Base64 Output

All methods support an optional `format` parameter:

```ruby
Philiprehberger::Checksum.sha256('hello', format: :base64)
# => "LPJNul+wow4m6DsqxbnO0eEWHiwe+nMzagMzC4uYK0Q="
```

## API

| Method | Description |
|--------|-------------|
| `Checksum.md5(string, format: :hex)` | MD5 checksum of a string |
| `Checksum.sha1(string, format: :hex)` | SHA-1 checksum of a string |
| `Checksum.sha256(string, format: :hex)` | SHA-256 checksum of a string |
| `Checksum.sha512(string, format: :hex)` | SHA-512 checksum of a string |
| `Checksum.crc32(string, format: :hex)` | CRC32 checksum of a string |
| `Checksum.file_md5(path, format: :hex)` | Streaming MD5 checksum of a file |
| `Checksum.file_sha256(path, format: :hex)` | Streaming SHA-256 checksum of a file |
| `Checksum.file_multi(path, *algos, format: :hex)` | Multi-algorithm single-pass file checksum |
| `Checksum.verify?(path, format: :hex, **expected)` | Verify file against expected checksums |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
