# frozen_string_literal: true

require 'base64'
require 'digest'
require 'openssl'
require 'zlib'

require_relative 'checksum/version'

module Philiprehberger
  module Checksum
    class Error < StandardError; end

    CHUNK_SIZE = 8192
    ALGORITHMS = {
      md5: Digest::MD5,
      sha1: Digest::SHA1,
      sha256: Digest::SHA256,
      sha512: Digest::SHA512
    }.freeze

    HMAC_ALGORITHMS = {
      sha256: 'SHA256',
      sha512: 'SHA512'
    }.freeze

    # Compute an MD5 checksum for a string
    #
    # @param string [String] the input string
    # @param format [Symbol] output format (:hex or :base64)
    # @return [String] the checksum
    def self.md5(string, format: :hex)
      digest_string(Digest::MD5, string, format: format)
    end

    # Compute a SHA-1 checksum for a string
    #
    # @param string [String] the input string
    # @param format [Symbol] output format (:hex or :base64)
    # @return [String] the checksum
    def self.sha1(string, format: :hex)
      digest_string(Digest::SHA1, string, format: format)
    end

    # Compute a SHA-256 checksum for a string
    #
    # @param string [String] the input string
    # @param format [Symbol] output format (:hex or :base64)
    # @return [String] the checksum
    def self.sha256(string, format: :hex)
      digest_string(Digest::SHA256, string, format: format)
    end

    # Compute a SHA-512 checksum for a string
    #
    # @param string [String] the input string
    # @param format [Symbol] output format (:hex or :base64)
    # @return [String] the checksum
    def self.sha512(string, format: :hex)
      digest_string(Digest::SHA512, string, format: format)
    end

    # Compute a CRC32 checksum for a string
    #
    # @param string [String] the input string
    # @param format [Symbol] output format (:hex or :base64)
    # @return [String] the checksum
    def self.crc32(string, format: :hex)
      value = Zlib.crc32(string)
      format_crc32(value, format: format)
    end

    # Compute an MD5 checksum for a file using streaming reads
    #
    # @param path [String] path to the file
    # @param format [Symbol] output format (:hex or :base64)
    # @return [String] the checksum
    # @raise [Error] if the file does not exist or is not readable
    def self.file_md5(path, format: :hex)
      digest_file(Digest::MD5, path, format: format)
    end

    # Compute a SHA-256 checksum for a file using streaming reads
    #
    # @param path [String] path to the file
    # @param format [Symbol] output format (:hex or :base64)
    # @return [String] the checksum
    # @raise [Error] if the file does not exist or is not readable
    def self.file_sha256(path, format: :hex)
      digest_file(Digest::SHA256, path, format: format)
    end

    # Compute multiple checksums for a file in a single read pass
    #
    # @param path [String] path to the file
    # @param algos [Array<Symbol>] algorithms to compute (:md5, :sha256, :sha512, :crc32)
    # @param format [Symbol] output format (:hex or :base64)
    # @return [Hash<Symbol, String>] algorithm => checksum pairs
    # @raise [Error] if the file does not exist or an unknown algorithm is given
    def self.file_multi(path, *algos, format: :hex)
      validate_file!(path)
      algos = algos.flatten
      raise Error, 'at least one algorithm is required' if algos.empty?

      digests = {}
      crc32_value = nil

      algos.each do |algo|
        if algo == :crc32
          crc32_value = 0
        elsif ALGORITHMS.key?(algo)
          digests[algo] = ALGORITHMS[algo].new
        else
          raise Error, "unknown algorithm: #{algo}"
        end
      end

      File.open(path, 'rb') do |io|
        while (chunk = io.read(CHUNK_SIZE))
          digests.each_value { |d| d.update(chunk) }
          crc32_value = Zlib.crc32(chunk, crc32_value) unless crc32_value.nil?
        end
      end

      result = {}
      algos.each do |algo|
        result[algo] = if algo == :crc32
                         format_crc32(crc32_value, format: format)
                       else
                         format_output(digests[algo], format: format)
                       end
      end
      result
    end

    # Compute an HMAC-SHA256 for a string
    #
    # @param string [String] the input string
    # @param key [String] the HMAC key
    # @param format [Symbol] output format (:hex or :base64)
    # @return [String] the HMAC digest
    def self.hmac_sha256(string, key:, format: :hex)
      hmac_digest('SHA256', string, key, format: format)
    end

    # Compute an HMAC-SHA512 for a string
    #
    # @param string [String] the input string
    # @param key [String] the HMAC key
    # @param format [Symbol] output format (:hex or :base64)
    # @return [String] the HMAC digest
    def self.hmac_sha512(string, key:, format: :hex)
      hmac_digest('SHA512', string, key, format: format)
    end

    # Compute a SHA-512 checksum for a file using streaming reads
    #
    # @param path [String] path to the file
    # @param format [Symbol] output format (:hex or :base64)
    # @return [String] the checksum
    # @raise [Error] if the file does not exist or is not readable
    def self.file_sha512(path, format: :hex)
      digest_file(Digest::SHA512, path, format: format)
    end

    # Compare two files by checksum
    #
    # @param path1 [String] path to the first file
    # @param path2 [String] path to the second file
    # @param algo [Symbol] algorithm to use (:md5, :sha1, :sha256, :sha512)
    # @return [Boolean] true if both files have the same checksum
    # @raise [Error] if either file does not exist or is not readable
    def self.compare_files(path1, path2, algo: :sha256)
      file_method = :"file_#{algo}"
      send(file_method, path1) == send(file_method, path2)
    end

    # Hash multiple files, returning a hash of { path => digest }
    #
    # @param paths [Array<String>] file paths to hash
    # @param algo [Symbol] algorithm (:md5, :sha1, :sha256, :sha512)
    # @param format [Symbol] output format (:hex or :base64)
    # @return [Hash<String, String>] path => digest pairs
    # @raise [Error] if any file does not exist or an unknown algorithm is given
    def self.files(paths, algo: :sha256, format: :hex)
      klass = ALGORITHMS[algo]
      raise Error, "unknown algorithm: #{algo}" unless klass

      paths.to_h do |path|
        [path, digest_file(klass, path, format: format)]
      end
    end

    # Verify an HMAC with timing-safe comparison
    #
    # @param string [String] the input string
    # @param expected [String] the expected HMAC hex digest
    # @param key [String] the HMAC key
    # @param algo [Symbol] algorithm (:sha256 or :sha512)
    # @return [Boolean] true if the HMAC matches
    def self.verify_hmac?(string, expected, key:, algo: :sha256)
      algo_name = HMAC_ALGORITHMS[algo]
      raise Error, "unknown HMAC algorithm: #{algo}" unless algo_name

      actual = hmac_digest(algo_name, string, key, format: :hex)
      secure_compare(actual, expected)
    end

    # Verify a file's checksum against expected values
    #
    # @param path [String] path to the file
    # @param format [Symbol] output format used for expected values
    # @param expected [Hash<Symbol, String>] algorithm => expected checksum pairs
    # @return [Boolean] true if all checksums match
    # @raise [Error] if the file does not exist or an unknown algorithm is given
    def self.verify?(path, format: :hex, **expected)
      raise Error, 'at least one expected checksum is required' if expected.empty?

      actual = file_multi(path, *expected.keys, format: format)
      expected.all? do |algo, expected_value|
        secure_compare(actual[algo], expected_value)
      end
    end

    # @api private
    def self.digest_string(klass, string, format: :hex)
      digest = klass.new
      digest.update(string)
      format_output(digest, format: format)
    end
    private_class_method :digest_string

    # @api private
    def self.digest_file(klass, path, format: :hex)
      validate_file!(path)
      digest = klass.new
      File.open(path, 'rb') do |io|
        digest.update(io.read(CHUNK_SIZE)) until io.eof?
      end
      format_output(digest, format: format)
    end
    private_class_method :digest_file

    # @api private
    def self.format_output(digest, format: :hex)
      case format
      when :hex then digest.hexdigest
      when :base64 then Base64.strict_encode64(digest.digest)
      else raise Error, "unknown format: #{format}"
      end
    end
    private_class_method :format_output

    # @api private
    def self.format_crc32(value, format: :hex)
      case format
      when :hex then format('%08x', value)
      when :base64 then Base64.strict_encode64([value].pack('N'))
      else raise Error, "unknown format: #{format}"
      end
    end
    private_class_method :format_crc32

    # @api private
    def self.validate_file!(path)
      raise Error, "file not found: #{path}" unless File.exist?(path)
      raise Error, "not a file: #{path}" unless File.file?(path)
      raise Error, "file not readable: #{path}" unless File.readable?(path)
    end
    private_class_method :validate_file!

    # @api private
    def self.hmac_digest(algo_name, string, key, format: :hex)
      raw = OpenSSL::HMAC.digest(algo_name, key, string)
      case format
      when :hex then OpenSSL::HMAC.hexdigest(algo_name, key, string)
      when :base64 then Base64.strict_encode64(raw)
      else raise Error, "unknown format: #{format}"
      end
    end
    private_class_method :hmac_digest

    # @api private
    def self.secure_compare(actual, expected)
      return false if actual.nil? || expected.nil?
      return false if actual.bytesize != expected.bytesize

      left = actual.unpack('C*')
      right = expected.unpack('C*')
      result = 0
      left.each_with_index { |byte, i| result |= byte ^ right[i] }
      result.zero?
    end
    private_class_method :secure_compare
  end
end
