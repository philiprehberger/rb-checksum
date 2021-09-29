# frozen_string_literal: true

require_relative 'lib/philiprehberger/checksum/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-checksum'
  spec.version = Philiprehberger::Checksum::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Simple file and string checksums with streaming support for large files'
  spec.description = 'Compute MD5, SHA-256, SHA-512, and CRC32 checksums for strings and files. ' \
                       'File checksums use streaming reads for constant memory usage. Supports ' \
                       'multi-algorithm single-pass computation and verification.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-checksum'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-checksum'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-checksum/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-checksum/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
