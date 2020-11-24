# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/reporters'
require 'pry'
Minitest::Reporters.use!
require File.expand_path('../lib/ngzip.rb', __dir__)
