# frozen_string_literal: true

require 'zlib'
require 'uri'
require 'erb'
require 'core_extensions/string/escape_glob'

String.include CoreExtensions::String::EscapeGlob

module Ngzip
  # The manifest builder based on the file list
  class Builder
    BUFFER_SIZE = 8 * 1024

    # Public: Build the files manifest for mod_zip, see http://wiki.nginx.org/NginxNgxZip for the specs.
    #
    # files - An Array of absolute file path elements
    # options - The options, see below
    #
    # Returns a line for each file separated by \n
    #
    # The following options are available:
    #  crc:         Enable or disable CRC-32 checksums
    #  crc_cache:   Allows for provided cached CRC-32 checksums in a hash where the key is the file path
    #  base_dir:    Use this as root for the relative pathes in the archive, keep all directories below
    def build(files, options = {})
      settings = { crc: true }
      settings.merge! options

      list = file_list(files)
      prefix = options[:base_dir] || detect_common_prefix(list)
      prefix += '/' unless prefix.end_with?('/')
      list.map do |f|
        format(
          '%<crc>s %<size>d %<url>s %<name>s',
          {
            crc: compute_crc32(f, settings),
            size: File.size(f).to_i,
            url: Builder.encode(f),
            name: f.gsub(prefix, '')
          }
        )
      end.join("\n")
    end

    # Public: Get the special header to signal the mod_zip
    #
    # Returns the header as a string "key: value"
    def header
      'X-Archive-Files: zip'
    end

    # Public: Encode the string
    #
    # Returns the encoded string using URL escape formatting
    def self.encode(string)
      ERB::Util.url_encode(string)
    end

    private

    # Internal: Compute a common prefix from a list of path elements
    #
    # list - The list of file path elements
    #
    # Returns a common prefix
    def detect_common_prefix(list)
      return File.dirname(list.first) if list.size == 1

      prefix = StringIO.new
      excluding_file_names = list.map { |p| File.dirname p }
      min, max = excluding_file_names.sort.values_at(0, -1)
      min.split(//).each_with_index do |c, i|
        break if c != max[i, 1]

        prefix << c
      end
      prefix.string
    end

    # Internal: Compute the file list by expanding directories
    #
    def file_list(files)
      Array(files).map do |e|
        if File.directory?(e)
          # `expand_path` removes any trailing slash from the path string
          # `String#escape_glob` handles bracket literals otherwise interpreted as glob control characters
          sanitized_path = File.expand_path(e.escape_glob)
          Dir.glob("#{sanitized_path}/**/*").reject { |f| File.directory?(f) }
        else
          e
        end
      end.flatten
    end

    # Internal: Compute the CRC-32 checksum for a file unless the settings
    # disable the computation (crc: false) and this method returns "-"
    #
    # file - The full path to the file
    # settings - The settings hash
    #
    # Returns a hex string
    def compute_crc32(file, settings)
      return '-' unless settings[:crc]

      # honor the cache
      return settings[:crc_cache][file] if settings[:crc_cache] && settings[:crc_cache][file]

      # read using a buffer, we might operate on large files!
      crc32 = 0
      File.open(file, 'rb') do |f|
        while (buffer = f.read(BUFFER_SIZE))
          crc32 = Zlib.crc32(buffer, crc32)
        end
      end
      crc32.to_s(16)
    end
  end
end
