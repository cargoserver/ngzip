# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ngzip/version'

Gem::Specification.new do |spec|
  spec.name          = "ngzip"
  spec.version       = Ngzip::VERSION
  spec.authors       = ["dup2"]
  spec.email         = ["zarkov@cargoserver.ch"]
  spec.description   = %q{Provides a nginx mod_zip compatible file manifest for streaming support.
                          See http://wiki.nginx.org/NginxNgxZip for the nginx module.}
  spec.summary       = %q{Provides a nginx mod_zip compatible file manifest for streaming support}
  spec.homepage      = "https://github.com/cargoserver/ngzip"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
