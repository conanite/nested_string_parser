lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nested_string_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "nested_string_parser"
  spec.version       = NestedStringParser::VERSION
  spec.authors       = ["Conan Dalton"]
  spec.email         = ["conan@conandalton.net"]
  spec.summary       = %q{Parse multi-line string with indentation, return a structure where nesting is based on line indentation}
  spec.description   = %q{Parse multi-line string with indentation, return a structure where nesting is based on line indentation}
  spec.homepage      = "http://github.com/conanite/nested_string_parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.1'
end
