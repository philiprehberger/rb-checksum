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
      result = described_class.md5('hello', format: :base64)
      expect(result).to be_a(String)
      expect(result).to end_with('==')
    end
  end

  describe '.sha1' do
    it 'computes SHA-1 for a string' do
      expect(described_class.sha1('hello')).to eq('aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d')
    end

    it 'computes SHA-1 for an empty string' do
      expect(described_class.sha1('')).to eq('da39a3ee5e6b4b0d3255bfef95601890afd80709')
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
      expect(result).to be_a(String)
      expect(result.length).to be > 0
    end
  end

  describe '.sha384' do
    it 'computes SHA-384 for a string' do
      result = described_class.sha384('hello')
      expect(result).to be_a(String)
      expect(result.length).to eq(96) # SHA-384 hex is 96 chars
      expect(result).to match(/\A[0-9a-f]{96}\z/)
    end

    it 'computes SHA-384 for an empty string' do
      expected = '38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da' \
                 '274edebfe76f65fbd51ad2f14898b95b'
      expect(described_class.sha384('')).to eq(expected)
    end

    it 'returns base64 when format is :base64' do
      result = described_class.sha384('hello', format: :base64)
      expect(result).to be_a(String)
      expect(result).not_to match(/\A[0-9a-f]+\z/)
    end
  end

  describe '.sha512' do
    it 'computes SHA-512 for a string' do
      result = described_class.sha512('hello')
      expect(result).to be_a(String)
      expect(result.length).to eq(128) # SHA-512 hex is 128 chars
      expect(result).to match(/\A[0-9a-f]{128}\z/)
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

  describe '.hmac_sha256' do
    it 'computes HMAC-SHA256 with known test vector' do
      # RFC 4231 test vector
      result = described_class.hmac_sha256('Hi There', key: "\x0b" * 20)
      expect(result).to eq('b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7')
    end

    it 'computes HMAC-SHA256 with string key' do
      result = described_class.hmac_sha256('message', key: 'secret')
      expect(result).to eq(OpenSSL::HMAC.hexdigest('SHA256', 'secret', 'message'))
    end

    it 'returns hex format by default' do
      result = described_class.hmac_sha256('hello', key: 'key')
      expect(result).to match(/\A[0-9a-f]{64}\z/)
    end

    it 'returns base64 when format is :base64' do
      result = described_class.hmac_sha256('hello', key: 'key', format: :base64)
      expect(result).to be_a(String)
      expect(result.length).to be > 0
      # Verify it decodes correctly
      decoded = Base64.strict_decode64(result)
      expect(decoded.bytesize).to eq(32) # SHA-256 is 32 bytes
    end

    it 'handles empty string' do
      result = described_class.hmac_sha256('', key: 'key')
      expect(result).to eq(OpenSSL::HMAC.hexdigest('SHA256', 'key', ''))
    end

    it 'handles empty key' do
      result = described_class.hmac_sha256('hello', key: '')
      expect(result).to eq(OpenSSL::HMAC.hexdigest('SHA256', '', 'hello'))
    end
  end

  describe '.hmac_sha512' do
    it 'computes HMAC-SHA512 with known test vector' do
      # RFC 4231 test vector
      result = described_class.hmac_sha512('Hi There', key: "\x0b" * 20)
      expect(result).to eq(
        '87aa7cdea5ef619d4ff0b4241a1d6cb02379f4e2ce4ec2787ad0b30545e17cde' \
        'daa833b7d6b8a702038b274eaea3f4e4be9d914eeb61f1702e696c203a126854'
      )
    end

    it 'computes HMAC-SHA512 with string key' do
      result = described_class.hmac_sha512('message', key: 'secret')
      expect(result).to eq(OpenSSL::HMAC.hexdigest('SHA512', 'secret', 'message'))
    end

    it 'returns hex format with 128 chars' do
      result = described_class.hmac_sha512('hello', key: 'key')
      expect(result).to match(/\A[0-9a-f]{128}\z/)
    end

    it 'handles empty string' do
      result = described_class.hmac_sha512('', key: 'key')
      expect(result).to eq(OpenSSL::HMAC.hexdigest('SHA512', 'key', ''))
    end
  end

  describe '.file_sha384' do
    it 'computes SHA-384 for a file' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_sha384(file.path)).to eq(described_class.sha384('hello'))
    ensure
      file&.unlink
    end

    it 'raises Error for nonexistent file' do
      expect { described_class.file_sha384('/nonexistent/file.txt') }.to raise_error(described_class::Error)
    end
  end

  describe '.hmac_sha384' do
    it 'computes HMAC-SHA384 for a string' do
      result = described_class.hmac_sha384('message', key: 'secret')
      expect(result).to eq(OpenSSL::HMAC.hexdigest('SHA384', 'secret', 'message'))
    end
  end

  describe '.file_sha512' do
    it 'computes SHA-512 for a file' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_sha512(file.path)).to eq(described_class.sha512('hello'))
    ensure
      file&.unlink
    end

    it 'matches string checksum for file contents' do
      content = 'the quick brown fox'
      file = Tempfile.new('checksum-test')
      file.write(content)
      file.close

      expect(described_class.file_sha512(file.path)).to eq(described_class.sha512(content))
    ensure
      file&.unlink
    end

    it 'handles empty files' do
      file = Tempfile.new('checksum-test')
      file.close

      expect(described_class.file_sha512(file.path)).to eq(described_class.sha512(''))
    ensure
      file&.unlink
    end

    it 'raises Error for nonexistent file' do
      expect { described_class.file_sha512('/nonexistent/file.txt') }.to raise_error(described_class::Error)
    end

    it 'returns base64 when format is :base64' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_sha512(file.path, format: :base64)).to eq(
        described_class.sha512('hello', format: :base64)
      )
    ensure
      file&.unlink
    end
  end

  describe '.files' do
    it 'hashes multiple files with default sha256' do
      file_a = Tempfile.new('checksum-a')
      file_a.write('alpha')
      file_a.close

      file_b = Tempfile.new('checksum-b')
      file_b.write('beta')
      file_b.close

      result = described_class.files([file_a.path, file_b.path])
      expect(result).to be_a(Hash)
      expect(result[file_a.path]).to eq(described_class.sha256('alpha'))
      expect(result[file_b.path]).to eq(described_class.sha256('beta'))
    ensure
      file_a&.unlink
      file_b&.unlink
    end

    it 'supports md5 algorithm' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      result = described_class.files([file.path], algo: :md5)
      expect(result[file.path]).to eq(described_class.md5('hello'))
    ensure
      file&.unlink
    end

    it 'supports sha512 algorithm' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      result = described_class.files([file.path], algo: :sha512)
      expect(result[file.path]).to eq(described_class.sha512('hello'))
    ensure
      file&.unlink
    end

    it 'supports sha1 algorithm' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      result = described_class.files([file.path], algo: :sha1)
      expect(result[file.path]).to eq(described_class.sha1('hello'))
    ensure
      file&.unlink
    end

    it 'raises Error for unknown algorithm' do
      file = Tempfile.new('checksum-test')
      file.close

      expect { described_class.files([file.path], algo: :unknown) }.to raise_error(described_class::Error)
    ensure
      file&.unlink
    end

    it 'raises Error for nonexistent file' do
      expect { described_class.files(['/nonexistent/file.txt']) }.to raise_error(described_class::Error)
    end

    it 'returns empty hash for empty paths array' do
      result = described_class.files([])
      expect(result).to eq({})
    end

    it 'supports base64 format' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      result = described_class.files([file.path], algo: :sha256, format: :base64)
      expect(result[file.path]).to eq(described_class.sha256('hello', format: :base64))
    ensure
      file&.unlink
    end
  end

  describe '.compare_files' do
    it 'returns true for files with identical content' do
      file_a = Tempfile.new('checksum-a')
      file_a.write('hello')
      file_a.close

      file_b = Tempfile.new('checksum-b')
      file_b.write('hello')
      file_b.close

      expect(described_class.compare_files(file_a.path, file_b.path)).to be true
    ensure
      file_a&.unlink
      file_b&.unlink
    end

    it 'returns false for files with different content' do
      file_a = Tempfile.new('checksum-a')
      file_a.write('hello')
      file_a.close

      file_b = Tempfile.new('checksum-b')
      file_b.write('world')
      file_b.close

      expect(described_class.compare_files(file_a.path, file_b.path)).to be false
    ensure
      file_a&.unlink
      file_b&.unlink
    end

    it 'uses sha256 by default' do
      file_a = Tempfile.new('checksum-a')
      file_a.write('hello')
      file_a.close

      file_b = Tempfile.new('checksum-b')
      file_b.write('hello')
      file_b.close

      expect(described_class).to receive(:file_digest).with(file_a.path, algo: :sha256).and_call_original
      expect(described_class).to receive(:file_digest).with(file_b.path, algo: :sha256).and_call_original
      described_class.compare_files(file_a.path, file_b.path)
    ensure
      file_a&.unlink
      file_b&.unlink
    end

    it 'supports md5 algorithm' do
      file_a = Tempfile.new('checksum-a')
      file_a.write('hello')
      file_a.close

      file_b = Tempfile.new('checksum-b')
      file_b.write('hello')
      file_b.close

      expect(described_class.compare_files(file_a.path, file_b.path, algo: :md5)).to be true
    ensure
      file_a&.unlink
      file_b&.unlink
    end

    it 'supports sha1 algorithm' do
      file_a = Tempfile.new('checksum-a')
      file_a.write('hello')
      file_a.close

      file_b = Tempfile.new('checksum-b')
      file_b.write('hello')
      file_b.close

      expect(described_class.compare_files(file_a.path, file_b.path, algo: :sha1)).to be true
    ensure
      file_a&.unlink
      file_b&.unlink
    end

    it 'supports sha512 algorithm' do
      file_a = Tempfile.new('checksum-a')
      file_a.write('hello')
      file_a.close

      file_b = Tempfile.new('checksum-b')
      file_b.write('hello')
      file_b.close

      expect(described_class.compare_files(file_a.path, file_b.path, algo: :sha512)).to be true
    ensure
      file_a&.unlink
      file_b&.unlink
    end

    it 'supports crc32 algorithm' do
      file_a = Tempfile.new('checksum-a')
      file_a.write('hello')
      file_a.close

      file_b = Tempfile.new('checksum-b')
      file_b.write('hello')
      file_b.close

      expect(described_class.compare_files(file_a.path, file_b.path, algo: :crc32)).to be true
    ensure
      file_a&.unlink
      file_b&.unlink
    end

    it 'raises Error for nonexistent file' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect { described_class.compare_files('/nonexistent/file.txt', file.path) }.to raise_error(described_class::Error)
    ensure
      file&.unlink
    end

    it 'returns true when comparing a file to itself' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.compare_files(file.path, file.path)).to be true
    ensure
      file&.unlink
    end

    it 'returns true for two empty files' do
      file_a = Tempfile.new('checksum-a')
      file_a.close

      file_b = Tempfile.new('checksum-b')
      file_b.close

      expect(described_class.compare_files(file_a.path, file_b.path)).to be true
    ensure
      file_a&.unlink
      file_b&.unlink
    end
  end

  describe '.compare_strings' do
    it 'returns true for equal strings' do
      expect(described_class.compare_strings('hello', 'hello')).to be true
    end

    it 'returns false for different strings' do
      expect(described_class.compare_strings('hello', 'world')).to be false
    end

    it 'works with :md5' do
      expect(described_class.compare_strings('hello', 'hello', algo: :md5)).to be true
      expect(described_class.compare_strings('hello', 'world', algo: :md5)).to be false
    end

    it 'raises Error for unknown algorithm' do
      expect { described_class.compare_strings('a', 'b', algo: :unknown) }.to raise_error(described_class::Error)
    end
  end

  describe '.file_sha1' do
    it 'computes SHA-1 for a file' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_sha1(file.path)).to eq(described_class.sha1('hello'))
    ensure
      file&.unlink
    end

    it 'handles empty files' do
      file = Tempfile.new('checksum-test')
      file.close

      expect(described_class.file_sha1(file.path)).to eq(described_class.sha1(''))
    ensure
      file&.unlink
    end

    it 'raises Error for nonexistent file' do
      expect { described_class.file_sha1('/nonexistent/file.txt') }.to raise_error(described_class::Error)
    end
  end

  describe '.file_crc32' do
    it 'computes CRC32 for a file' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_crc32(file.path)).to eq(described_class.crc32('hello'))
    ensure
      file&.unlink
    end

    it 'handles empty files' do
      file = Tempfile.new('checksum-test')
      file.close

      expect(described_class.file_crc32(file.path)).to eq(described_class.crc32(''))
    ensure
      file&.unlink
    end

    it 'returns base64 when format is :base64' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_crc32(file.path, format: :base64)).to eq(
        described_class.crc32('hello', format: :base64)
      )
    ensure
      file&.unlink
    end

    it 'raises Error for nonexistent file' do
      expect { described_class.file_crc32('/nonexistent/file.txt') }.to raise_error(described_class::Error)
    end
  end

  describe '.digest' do
    it 'dispatches to md5' do
      expect(described_class.digest('hello', algo: :md5)).to eq(described_class.md5('hello'))
    end

    it 'dispatches to sha1' do
      expect(described_class.digest('hello', algo: :sha1)).to eq(described_class.sha1('hello'))
    end

    it 'dispatches to sha256' do
      expect(described_class.digest('hello', algo: :sha256)).to eq(described_class.sha256('hello'))
    end

    it 'dispatches to sha512' do
      expect(described_class.digest('hello', algo: :sha512)).to eq(described_class.sha512('hello'))
    end

    it 'dispatches to crc32' do
      expect(described_class.digest('hello', algo: :crc32)).to eq(described_class.crc32('hello'))
    end

    it 'supports base64 format' do
      expect(described_class.digest('hello', algo: :sha256, format: :base64)).to eq(
        described_class.sha256('hello', format: :base64)
      )
    end

    it 'raises Error for unknown algorithm' do
      expect { described_class.digest('hello', algo: :unknown) }.to raise_error(described_class::Error)
    end
  end

  describe '.file_digest' do
    it 'dispatches to all supported algorithms' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      %i[md5 sha1 sha256 sha512 crc32].each do |algo|
        expect(described_class.file_digest(file.path, algo: algo)).to eq(
          described_class.digest('hello', algo: algo)
        )
      end
    ensure
      file&.unlink
    end

    it 'raises Error for unknown algorithm' do
      file = Tempfile.new('checksum-test')
      file.close

      expect { described_class.file_digest(file.path, algo: :unknown) }.to raise_error(described_class::Error)
    ensure
      file&.unlink
    end

    it 'raises Error for nonexistent file' do
      expect { described_class.file_digest('/nonexistent/file.txt', algo: :sha256) }.to raise_error(described_class::Error)
    end
  end

  describe '.verify_hmac?' do
    it 'returns true for correct HMAC' do
      hmac = described_class.hmac_sha256('message', key: 'secret')
      expect(described_class.verify_hmac?('message', hmac, key: 'secret')).to be true
    end

    it 'returns false for incorrect HMAC' do
      expect(described_class.verify_hmac?('message', 'wrong', key: 'secret')).to be false
    end

    it 'returns false for tampered message' do
      hmac = described_class.hmac_sha256('message', key: 'secret')
      expect(described_class.verify_hmac?('tampered', hmac, key: 'secret')).to be false
    end

    it 'returns false for wrong key' do
      hmac = described_class.hmac_sha256('message', key: 'secret')
      expect(described_class.verify_hmac?('message', hmac, key: 'wrong')).to be false
    end

    it 'supports sha512 algorithm' do
      hmac = described_class.hmac_sha512('message', key: 'secret')
      expect(described_class.verify_hmac?('message', hmac, key: 'secret', algo: :sha512)).to be true
    end

    it 'returns false for sha512 with wrong value' do
      expect(described_class.verify_hmac?('message', 'wrong', key: 'secret', algo: :sha512)).to be false
    end

    it 'raises Error for unknown algorithm' do
      expect { described_class.verify_hmac?('msg', 'hmac', key: 'k', algo: :md5) }.to raise_error(described_class::Error)
    end

    it 'handles empty string' do
      hmac = described_class.hmac_sha256('', key: 'secret')
      expect(described_class.verify_hmac?('', hmac, key: 'secret')).to be true
    end

    it 'handles empty key' do
      hmac = described_class.hmac_sha256('hello', key: '')
      expect(described_class.verify_hmac?('hello', hmac, key: '')).to be true
    end
  end

  describe '.file_md5' do
    it 'computes MD5 for a file' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_md5(file.path)).to eq(described_class.md5('hello'))
    ensure
      file&.unlink
    end

    it 'matches string checksum for file contents' do
      content = 'the quick brown fox'
      file = Tempfile.new('checksum-test')
      file.write(content)
      file.close

      expect(described_class.file_md5(file.path)).to eq(described_class.md5(content))
    ensure
      file&.unlink
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

  describe '.files with crc32' do
    it 'supports crc32 algorithm' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      result = described_class.files([file.path], algo: :crc32)
      expect(result[file.path]).to eq(described_class.crc32('hello'))
    ensure
      file&.unlink
    end
  end

  describe '.directory_checksum' do
    it 'computes a combined checksum for a directory' do
      dir = Dir.mktmpdir
      File.write(File.join(dir, 'a.txt'), 'alpha')
      File.write(File.join(dir, 'b.txt'), 'beta')

      result = described_class.directory_checksum(dir)
      expect(result).to be_a(String)
      expect(result).to match(/\A[0-9a-f]{64}\z/)
    ensure
      FileUtils.rm_rf(dir)
    end

    it 'returns different checksums for different contents' do
      dir1 = Dir.mktmpdir
      File.write(File.join(dir1, 'a.txt'), 'alpha')

      dir2 = Dir.mktmpdir
      File.write(File.join(dir2, 'a.txt'), 'beta')

      expect(described_class.directory_checksum(dir1)).not_to eq(described_class.directory_checksum(dir2))
    ensure
      FileUtils.rm_rf(dir1)
      FileUtils.rm_rf(dir2)
    end

    it 'returns same checksum for identical directories' do
      dir1 = Dir.mktmpdir
      File.write(File.join(dir1, 'a.txt'), 'hello')

      dir2 = Dir.mktmpdir
      File.write(File.join(dir2, 'a.txt'), 'hello')

      expect(described_class.directory_checksum(dir1)).to eq(described_class.directory_checksum(dir2))
    ensure
      FileUtils.rm_rf(dir1)
      FileUtils.rm_rf(dir2)
    end

    it 'detects different filenames with same content' do
      dir1 = Dir.mktmpdir
      File.write(File.join(dir1, 'a.txt'), 'hello')

      dir2 = Dir.mktmpdir
      File.write(File.join(dir2, 'b.txt'), 'hello')

      expect(described_class.directory_checksum(dir1)).not_to eq(described_class.directory_checksum(dir2))
    ensure
      FileUtils.rm_rf(dir1)
      FileUtils.rm_rf(dir2)
    end

    it 'handles empty directories' do
      dir = Dir.mktmpdir
      result = described_class.directory_checksum(dir)
      expect(result).to be_a(String)
    ensure
      FileUtils.rm_rf(dir)
    end

    it 'supports md5 algorithm' do
      dir = Dir.mktmpdir
      File.write(File.join(dir, 'a.txt'), 'hello')

      result = described_class.directory_checksum(dir, algo: :md5)
      expect(result).to match(/\A[0-9a-f]{32}\z/)
    ensure
      FileUtils.rm_rf(dir)
    end

    it 'raises Error for non-directory path' do
      file = Tempfile.new('checksum-test')
      file.close

      expect { described_class.directory_checksum(file.path) }.to raise_error(described_class::Error)
    ensure
      file&.unlink
    end
  end

  describe '.hmac_sha1' do
    it 'computes HMAC-SHA1 matching OpenSSL' do
      result = described_class.hmac_sha1('message', key: 'secret')
      expect(result).to eq(OpenSSL::HMAC.hexdigest('SHA1', 'secret', 'message'))
    end

    it 'returns a 40-char hex digest' do
      result = described_class.hmac_sha1('hello', key: 'key')
      expect(result).to match(/\A[0-9a-f]{40}\z/)
    end

    it 'returns base64 when format is :base64' do
      result = described_class.hmac_sha1('hello', key: 'key', format: :base64)
      decoded = Base64.strict_decode64(result)
      expect(decoded.bytesize).to eq(20) # SHA-1 is 20 bytes
    end

    it 'handles empty string' do
      result = described_class.hmac_sha1('', key: 'key')
      expect(result).to eq(OpenSSL::HMAC.hexdigest('SHA1', 'key', ''))
    end

    it 'handles empty key' do
      result = described_class.hmac_sha1('hello', key: '')
      expect(result).to eq(OpenSSL::HMAC.hexdigest('SHA1', '', 'hello'))
    end

    it 'raises Error for unknown format' do
      expect { described_class.hmac_sha1('hello', key: 'k', format: :bogus) }.to raise_error(described_class::Error)
    end

    it 'is recognized by verify_hmac?' do
      hmac = described_class.hmac_sha1('message', key: 'secret')
      expect(described_class.verify_hmac?('message', hmac, key: 'secret', algo: :sha1)).to be true
    end
  end

  describe '.verify_string?' do
    it 'returns true when the checksum matches (default sha256)' do
      expect(described_class.verify_string?('hello', described_class.sha256('hello'))).to be true
    end

    it 'returns false when the checksum does not match' do
      expect(described_class.verify_string?('hello', 'wrong')).to be false
    end

    it 'supports md5' do
      expect(described_class.verify_string?('hello', described_class.md5('hello'), algo: :md5)).to be true
    end

    it 'supports sha1' do
      expect(described_class.verify_string?('hello', described_class.sha1('hello'), algo: :sha1)).to be true
    end

    it 'supports sha512' do
      expect(described_class.verify_string?('hello', described_class.sha512('hello'), algo: :sha512)).to be true
    end

    it 'supports crc32' do
      expect(described_class.verify_string?('hello', described_class.crc32('hello'), algo: :crc32)).to be true
    end

    it 'supports base64 format' do
      b64 = described_class.sha256('hello', format: :base64)
      expect(described_class.verify_string?('hello', b64, format: :base64)).to be true
    end

    it 'returns false when the expected value is nil' do
      expect(described_class.verify_string?('hello', nil)).to be false
    end

    it 'returns false for mismatched byte sizes' do
      expect(described_class.verify_string?('hello', 'abc')).to be false
    end

    it 'raises Error for unknown algorithm' do
      expect { described_class.verify_string?('hello', 'abc', algo: :unknown) }.to raise_error(described_class::Error)
    end

    it 'handles empty strings' do
      expect(described_class.verify_string?('', described_class.sha256(''))).to be true
    end
  end

  describe '.file_hmac' do
    it 'computes HMAC-SHA256 for a file matching the string version' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_hmac(file.path, key: 'secret')).to eq(
        described_class.hmac_sha256('hello', key: 'secret')
      )
    ensure
      file&.unlink
    end

    it 'supports sha1 algorithm' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_hmac(file.path, key: 'k', algo: :sha1)).to eq(
        described_class.hmac_sha1('hello', key: 'k')
      )
    ensure
      file&.unlink
    end

    it 'supports sha512 algorithm' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_hmac(file.path, key: 'k', algo: :sha512)).to eq(
        described_class.hmac_sha512('hello', key: 'k')
      )
    ensure
      file&.unlink
    end

    it 'returns base64 when format is :base64' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect(described_class.file_hmac(file.path, key: 'k', format: :base64)).to eq(
        described_class.hmac_sha256('hello', key: 'k', format: :base64)
      )
    ensure
      file&.unlink
    end

    it 'handles empty files' do
      file = Tempfile.new('checksum-test')
      file.close

      expect(described_class.file_hmac(file.path, key: 'k')).to eq(
        described_class.hmac_sha256('', key: 'k')
      )
    ensure
      file&.unlink
    end

    it 'raises Error for nonexistent file' do
      expect { described_class.file_hmac('/nonexistent/file.txt', key: 'k') }.to raise_error(described_class::Error)
    end

    it 'raises Error for unknown algorithm' do
      file = Tempfile.new('checksum-test')
      file.close

      expect { described_class.file_hmac(file.path, key: 'k', algo: :md5) }.to raise_error(described_class::Error)
    ensure
      file&.unlink
    end

    it 'raises Error for unknown format' do
      file = Tempfile.new('checksum-test')
      file.write('hello')
      file.close

      expect { described_class.file_hmac(file.path, key: 'k', format: :bogus) }.to raise_error(described_class::Error)
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
