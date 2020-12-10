# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/ecg/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-ecg"
  spec.version       = Rack::ECG::VERSION
  spec.authors       = ["Envato", "Julian Doherty"]
  spec.email         = ["julian@envato.com"]
  spec.summary       = 'Rack middleware serving a health check page'
  spec.description   = <<-EOF
    rack-ecg allows you to serve a page that shows you facts about your deployed
    app to allow you to check that everything is running as it should: git
    revision, database migrations, and more
  EOF
  spec.homepage      = "https://github.com/envato/rack-ecg"
  spec.license       = "MIT"

  spec.files         = %x(git ls-files -z).split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4"

  spec.add_runtime_dependency("rack")

  spec.add_development_dependency("rake", "~> 13.0")
  spec.add_development_dependency("bundler", "~> 2.2.0")
  spec.add_development_dependency("rspec", "~> 3.9.0")
  spec.add_development_dependency("rack-test", "~> 1.1.0")
  spec.add_development_dependency("pry", "~> 0.13.0")
  spec.add_development_dependency("rubocop-shopify", "~> 1.0.0")
  spec.add_development_dependency("yard", "~> 0.9.24")
  spec.add_development_dependency("redcarpet", "~> 3.5.0")
end
