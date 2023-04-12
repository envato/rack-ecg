# coding: utf-8
# frozen_string_literal: true

require_relative "lib/rack/ecg/version"

Gem::Specification.new do |spec|
  spec.name          = "rack-ecg"
  spec.version       = Rack::ECG::VERSION
  spec.authors       = ["Envato", "Julian Doherty"]
  spec.email         = ["julian@envato.com"]
  spec.summary       = "Rack middleware serving a health check page"
  spec.description   = <<-EOF
    rack-ecg allows you to serve a page that shows you facts about your deployed
    app to allow you to check that everything is running as it should: git
    revision, database migrations, and more
  EOF
  spec.homepage      = "https://github.com/envato/rack-ecg"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/envato/rack-ecg/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    %x(git ls-files -z).split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.add_runtime_dependency("rack")

  spec.add_development_dependency("pry", "~> 0.14.1")
  spec.add_development_dependency("rack-test", "~> 2.1.0")
  spec.add_development_dependency("rake", "~> 13.0")
  spec.add_development_dependency("redcarpet", "~> 3.5.0")
  spec.add_development_dependency("rspec", "~> 3.11.0")
  spec.add_development_dependency("rubocop-shopify", "~> 2.10")
  spec.add_development_dependency("yard", "~> 0.9.24")
end
