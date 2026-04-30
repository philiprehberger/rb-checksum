# philiprehberger-checksum

[![Tests](https://github.com/philiprehberger/rb-checksum/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-checksum/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-checksum.svg)](https://rubygems.org/gems/philiprehberger-checksum)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-checksum)](https://github.com/philiprehberger/rb-checksum/commits/main)

Simple file and string checksums with HMAC support and streaming for large files

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-checksum"
```

Or install directly:

```bash
gem install philiprehberger-checksum
```

## Usage

```ruby
require "philiprehberger/checksum"

Philiprehberger::Checksum.sha256('hello')  # => "2cf24dba5fb0a30e..."
```

### String Checksums

```ruby
Philiprehberger::Checksum.md5('hello')     # => "5d41402abc4b2a76..."
Philiprehberger::Checksum.sha1('hello')    # => "aaf4c61ddcc5e8a2..."
Philiprehberger::Checksum.sha256('hello')  # => "2cf24dba5fb0a30e..."
Philiprehberger::Checksum.sha384('hello')  # => "59e1748777448c69..."
Philiprehberger::Checksum.sha512('hello')  # => "9b71d224bd62f378..."
Philiprehberger::Checksum.crc32('hello')   # => "3610a686"
```

### File Checksums

File checksums use streaming reads in 8KB chunks for constant memory usage:

```ruby
Philiprehberger::Checksum.file_md5('/path/to/file')
Philiprehberger::Checksum.file_sha256('/path/to/file')
Philiprehberger::Checksum.file_sha384('/path/to/file')
Philiprehberger::Checksum.file_sha512('/path/to/file')
```

### Compare Files

Check if two files have the same checksum:

```ruby
Philiprehberger::Checksum.compare_files('/path/to/file_a', '/path/to/file_b')
# => true or false

Philiprehberger::Checksum.compare_files('/path/to/file_a', '/path/to/file_b', algo: :md5)
# => true or false
```

### Compare Strings

Check if two strings have the same checksum:

```ruby
Philiprehberger::Checksum.compare_strings('hello', 'hello')
# => true

Philiprehberger::Checksum.compare_strings('hello', 'world', algo: :md5)
# => false
```

### Multi-File Hashing

Hash multiple files in one call:

```ruby
digests = Philiprehberger::Checksum.files(['/path/to/a.txt', '/path/to/b.txt'], algo: :sha256)
# => { "/path/to/a.txt" => "abc123...", "/path/to/b.txt" => "def456..." }
```

### HMAC

Compute HMAC digests with a secret key:

```ruby
Philiprehberger::Checksum.hmac_sha1('message', key: 'secret')
# => "0caf649feee4953d87bf903ac1176c45e028df16"

Philiprehberger::Checksum.hmac_sha256('message', key: 'secret')
# => "8b5f48702995c1598c573db1e21866a9b825d4a794d169d7060a03605796360b"

Philiprehberger::Checksum.hmac_sha384('message', key: 'secret')
# => hex string

Philiprehberger::Checksum.hmac_sha512('message', key: 'secret')
# => hex string

Philiprehberger::Checksum.hmac_sha256('message', key: 'secret', format: :base64)
# => base64 string
```

### File HMAC

Stream an HMAC over a file's contents without loading it into memory:

```ruby
Philiprehberger::Checksum.file_hmac('/path/to/file', key: 'secret')
# => "8b5f48702995c1598c573db1e21866a9b825d4a794d169d7060a03605796360b"

Philiprehberger::Checksum.file_hmac('/path/to/file', key: 'secret', algo: :sha512)
# => hex string

Philiprehberger::Checksum.file_hmac('/path/to/file', key: 'secret', format: :base64)
```

### HMAC Verification

Verify an HMAC with timing-safe comparison:

```ruby
hmac = Philiprehberger::Checksum.hmac_sha256('message', key: 'secret')
Philiprehberger::Checksum.verify_hmac?('message', hmac, key: 'secret')
# => true
```

### String Verification

Verify a string against an expected checksum with timing-safe comparison:

```ruby
expected = Philiprehberger::Checksum.sha256('hello')
Philiprehberger::Checksum.verify_string?('hello', expected)
# => true

Philiprehberger::Checksum.verify_string?('hello', 'wrong', algo: :md5)
# => false
```

### Generic Dispatch

Use `digest` and `file_digest` when the algorithm is determined at runtime:

```ruby
Philiprehberger::Checksum.digest("hello", algo: :sha256)
# => "2cf24dba5fb0a30e..."

Philiprehberger::Checksum.file_digest("/path/to/file", algo: :crc32)
# => "3610a686"
```

Both accept `:md5`, `:sha1`, `:sha256`, `:sha384`, `:sha512`, and `:crc32`.

### IO Digests

Stream a digest from any IO-like object — useful when the source isn't a
file path (sockets, pipes, in-memory buffers).

```ruby
require 'stringio'

io = StringIO.new('streaming content')
Philiprehberger::Checksum.io_digest(io, algo: :sha256)
# => "..."

# Same digest as the string-based API:
Philiprehberger::Checksum.digest('streaming content', algo: :sha256)
```

### Directory Checksum

Compute a combined checksum of all files in a directory:

```ruby
Philiprehberger::Checksum.directory_checksum('/path/to/dir')
# => "a1b2c3d4..." (single SHA-256 digest of all files)

Philiprehberger::Checksum.directory_checksum('/path/to/dir', algo: :md5)
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
| `Checksum.hmac_sha1(string, key:, format: :hex)` | HMAC-SHA1 digest of a string |
| `Checksum.hmac_sha256(string, key:, format: :hex)` | HMAC-SHA256 digest of a string |
| `Checksum.hmac_sha512(string, key:, format: :hex)` | HMAC-SHA512 digest of a string |
| `Checksum.file_hmac(path, key:, algo: :sha256, format: :hex)` | Streaming HMAC digest of a file |
| `Checksum.digest(string, algo:, format: :hex)` | Checksum of a string using any algorithm |
| `Checksum.file_digest(path, algo:, format: :hex)` | Streaming file checksum using any algorithm |
| `Checksum.file_md5(path, format: :hex)` | Streaming MD5 checksum of a file |
| `Checksum.file_sha1(path, format: :hex)` | Streaming SHA-1 checksum of a file |
| `Checksum.file_sha256(path, format: :hex)` | Streaming SHA-256 checksum of a file |
| `Checksum.file_sha512(path, format: :hex)` | Streaming SHA-512 checksum of a file |
| `Checksum.file_crc32(path, format: :hex)` | Streaming CRC32 checksum of a file |
| `Checksum.io_digest(io, algo: :sha256, format: :hex)` | Streaming checksum of any IO-like object (e.g. `StringIO`) |
| `Checksum.compare_files(path1, path2, algo: :sha256)` | Compare two files by checksum |
| `Checksum.compare_strings(s1, s2, algo: :sha256)` | Compare two strings by checksum |
| `Checksum.files(paths, algo:, format: :hex)` | Hash multiple files, returns `{ path => digest }` |
| `Checksum.file_multi(path, *algos, format: :hex)` | Multi-algorithm single-pass file checksum |
| `Checksum.verify?(path, format: :hex, **expected)` | Verify file against expected checksums |
| `Checksum.verify_string?(string, expected, algo: :sha256, format: :hex)` | Timing-safe verification of a string checksum |
| `Checksum.directory_checksum(path, algo:, format:)` | Combined checksum of all files in a directory |
| `Checksum.verify_hmac?(string, expected, key:, algo:)` | Timing-safe HMAC verification |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-checksum)

🐛 [Report issues](https://github.com/philiprehberger/rb-checksum/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-checksum/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
