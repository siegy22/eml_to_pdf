# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eml_to_pdf/version'

Gem::Specification.new do |spec|
  spec.name          = "eml_to_pdf"
  spec.version       = EmlToPdf::VERSION
  spec.authors       = ["Yves Siegrist"]
  spec.email         = ["Elektron1c97@gmail.com"]

  spec.summary       = %q{This gem allows you to convert an eml (email) into a pdf.}
  spec.homepage      = "https://github.com/Elektron1c97/eml_to_pdf"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'filesize'
  spec.add_dependency 'mail'
  spec.add_dependency 'nokogiri'
end
