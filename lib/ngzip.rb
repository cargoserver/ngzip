# frozen_string_literal: true

require 'ngzip/version'
require 'ngzip/builder'

# Ngzip module
module Ngzip
  def self.build(files, options)
    Ngzip::Builder.new.build(files, options)
  end
end
