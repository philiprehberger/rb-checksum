# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe Philiprehberger::Checksum do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.md5' do
    it 'computes MD5 for a string' do
      expect(described_class.md5('hello')).to eq('5d41402abc4b2a76b9719d911017c592')
    end

    it 'computes MD5 for an empty string' do
      expect(described_class.md5('')).to eq('d41d8cd98f00b204e9800998ecf8427e')
    end

    it 'returns base64 when format is :base64' do
      expect(described_class.md5('hello', format: :base64)).to eq('XUFAKrxLKna5cZ2REBfFkg==')
    end
  end

  describe '.sha256' do
    it 'computes SHA-256 for a string' do
      expect(described_class.sha256('hello')).to eq('2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824')
    end

    it 'computes SHA-256 for an empty string' do
      expect(described_class.sha256('')).to eq('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855')
    end

    it 'returns base64 when format is :base64' do
      result = described_class.sha256('hello', format: :base64)
      expect(result).to eq('LPJNul+wow4m6DsqxbnO0eEWHiwe+nMzagMzC4uYK0Q=')
    end
  end

  describe '.sha512' do
    it 'computes SHA-512 for a string' do
      expected = '9b71d224bd62f3785d96d46ad3ea3d73c3b0b6b5fbc5ba91f8eb0e6ae4d6b0f3' \
                 '2025e2d8ab0e8769cf9b2eb910fc635418a508c87ebf09c5bd91085017b2e386'
      expect(described_class.sha512('hello')).to eq(expected)
    end

    it 'computes SHA-512 for an empty string' do
      expected = 'cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce' \
                 '47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e'
      expect(described_class.sha512('')).to eq(expected)
    end
  end

  describe '.crc32' do
    it 'computes CRC32 for a string' do
      expect(described_class.crc32('hello')).to eq('3610a686')
    end

    it 'computes CRC32 for an empty string' do
      expect(described_class.crc32('')).to eq('00000000')
    end

    it 'returns base64 when format is :base64' do
      result = described_class.crc32('hello', format: :base64)
      expect(result).to eq('NhCmhg==')
    end
  end

  describe '.file_sha256' do
    it 'computes SHA-256 for a file' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_sha256(file.path)).to eq(described_class.sha256('hello'))
    ensure
      file&.unlink
    end

    it 'matches string checksum for file contents' do
      content = 'the quick brown fox jumps over the lazy dog'
      file = Tempfile.new('checksum-test')
      file.write(content)
      file.close

      expect(described_class.file_sha256(file.path)).to eq(described_class.sha256(content))
    ensure
      file&.unlink
    end

    it 'handles empty files' do
      file = Tempfile.new('checksum-test')
      file.close

      expect(described_class.file_sha256(file.path)).to eq(described_class.sha256(''))
    ensure
      file&.unlink
    end

    it 'raises Error for nonexistent file' do
      expect { described_class.file_sha256('/nonexistent/file.txt') }.to raise_error(described_class::Error)
    end

    it 'returns base64 when format is :base64' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_sha256(file.path, format: :base64)).to eq(
        described_class.sha256('hello', format: :base64)
      )
    ensure
      file&.unlink
    end
  end

  describe '.file_multi' do
    it 'computes multiple algorithms in a single pass' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      result = described_class.file_multi(file.path, :md5, :sha256)
      expect(result[:md5]).to eq(described_class.md5('hello'))
      expect(result[:sha256]).to eq(described_class.sha256('hello'))
    ensure
      file&.unlink
    end

    it 'supports all four algorithms' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      result = described_class.file_multi(file.path, :md5, :sha256, :sha512, :crc32)
      expect(result[:md5]).to eq(described_class.md5('hello'))
      expect(result[:sha256]).to eq(described_class.sha256('hello'))
      expect(result[:sha512]).to eq(described_class.sha512('hello'))
      expect(result[:crc32]).to eq(described_class.crc32('hello'))
    ensure
      file&.unlink
    end

    it 'raises Error for unknown algorithm' do
      file = Tempfile.new('checksum-test')
      file.close

      expect { described_class.file_multi(file.path, :unknown) }.to raise_error(described_class::Error)
    ensure
      file&.unlink
    end

    it 'raises Error when no algorithms given' do
      file = Tempfile.new('checksum-test')
      file.close

      expect { described_class.file_multi(file.path) }.to raise_error(described_class::Error)
    ensure
      file&.unlink
    end

    it 'handles empty files' do
      file = Tempfile.new('checksum-test')
      file.close

      result = described_class.file_multi(file.path, :md5, :crc32)
      expect(result[:md5]).to eq(described_class.md5(''))
      expect(result[:crc32]).to eq(described_class.crc32(''))
    ensure
      file&.unlink
    end
  end

  describe '.verify?' do
    it 'returns true when checksum matches' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.verify?(file.path, sha256: described_class.sha256('hello'))).to be true
    ensure
      file&.unlink
    end

    it 'returns false when checksum does not match' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.verify?(file.path, sha256: 'wrong')).to be false
    ensure
      file&.unlink
    end

    it 'verifies multiple algorithms at once' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      result = described_class.verify?(
        file.path,
        md5: described_class.md5('hello'),
        sha256: described_class.sha256('hello')
      )
      expect(result).to be true
    ensure
      file&.unlink
    end

    it 'returns false if any algorithm does not match' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      result = described_class.verify?(
        file.path,
        md5: described_class.md5('hello'),
        sha256: 'wrong'
      )
      expect(result).to be false
    ensure
      file&.unlink
    end

    it 'raises Error when no expected checksums given' do
      file = Tempfile.new('checksum-test')
      file.close

      expect { described_class.verify?(file.path) }.to raise_error(described_class::Error)
    ensure
      file&.unlink
    end

    it 'raises Error for nonexistent file' do
      expect do
        described_class.verify?('/nonexistent/file.txt', sha256: 'abc')
      end.to raise_error(described_class::Error)
    end
  end
end
