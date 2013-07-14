require "ngzip/version"
require "ngzip/builder"

module Ngzip
  def self.build(files, options)
    Ngzip::Builder.new().build(files, options)
  end
end
