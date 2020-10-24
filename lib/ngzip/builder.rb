require 'zlib'
require 'uri'
require 'erb'

module Ngzip
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
    #  :crc         => Enable or disable CRC-32 checksums
    #  :crc_cache   => Allows for provided cached CRC-32 checksums in a hash where the key is the file path
    #  :base_dir    => Use this as root for the relative pathes in the archive, keep all directories below
    def build(files, options = {})
      settings = {:crc => true}
      settings.merge! options

      list = file_list(files)
      prefix = options[:base_dir] || detect_common_prefix(list)
      prefix += '/' unless prefix.end_with?('/')
      list.map do |f|
        sprintf('%s %d %s %s',
                compute_crc32(f, settings),
                File.size(f).to_i,
                Builder.encode(f),
                f.gsub(prefix, '')
        )
      end.join("\n")
    end

    # Public: Get the special header to signal the mod_zip
    #
    # Returns the header as a string "key: value"
    def header()
      "X-Archive-Files: zip"
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
      if list.size == 1
        return File.dirname(list.first)
      end
      prefix = ''
      excluding_file_names = list.map { |p| File.dirname p }
      min, max = excluding_file_names.sort.values_at(0, -1)
      min.split(//).each_with_index do |c, i|
        break if c != max[i, 1]
        prefix << c
      end
      prefix
    end

    # Internal: Compute the file list by expanding directories
    #
    def file_list(files)
      Array(files).map do |e|
        if File.directory?(e)
          Dir.glob("#{e}/**/*").reject { |f| File.directory?(f) }
        else
          e
        end
      end.flatten
    end

    # Internal: Compute the CRC-32 checksum for a file unless the settings
    # disable the computation (:crc => false) and this method returns "-"
    #
    # file - The full path to the file
    # settings - The settings hash
    #
    # Returns a hex string
    def compute_crc32(file, settings)
      return '-' unless settings[:crc]

      # honor the cache
      if settings[:crc_cache] && settings[:crc_cache][file]
        return settings[:crc_cache][file]
      end

      # read using a buffer, we might operate on large files!
      crc32 = 0
      File.open(file,'rb') do |f|
        while buffer = f.read(BUFFER_SIZE) do
          crc32 = Zlib.crc32(buffer, crc32)
        end
      end
      crc32.to_s(16)
    end
  end
end
