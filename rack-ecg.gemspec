# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/ecg/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-ecg"
  spec.version       = Rack::ECG::VERSION
  spec.authors       = ["Envato", "Julian Doherty"]
  spec.email         = ["julian@envato.com"]
  spec.summary       = %q{Rack middleware serving a health check page}
  spec.description   = %q{rack-ecg allows you to serve a page that shows you facts about your deployed app to allow you to check that everything is running as it should: git revision, database migrations, and more}
  spec.homepage      = "https://github.com/envato/rack-ecg"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rack"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2.0"
  spec.add_development_dependency "rack-test", "~> 0.6.3"
  spec.add_development_dependency "pry", "~> 0.10.1"
end
