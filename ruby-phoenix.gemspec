# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'phoenix/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-phoenix"
  spec.version       = Ruby::Phoenix::VERSION
  spec.authors       = ["wxianfeng"]
  spec.email         = ["wang.fl1429@gmail.com"]
  spec.summary       = %q{Ruby Client SDK For Apache Phoenix.}
  spec.description   = %q{Ruby Client SDK For Apache Phoenix.}
  spec.homepage      = "https://github.com/wxianfeng/ruby-phoenix"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rake", "~> 10.4"
  spec.add_dependency "rjb", "~> 1.4"
  spec.add_dependency "activesupport", "~> 4.2"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "pry", "~> 0.10"
end
