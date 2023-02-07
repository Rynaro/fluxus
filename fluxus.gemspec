# frozen_string_literal: true

require_relative 'lib/fluxus/version'

Gem::Specification.new do |spec|
  spec.name = 'fluxus'
  spec.version = Fluxus::VERSION
  spec.authors = ['Henrique Aparecido Lavezzo']
  spec.email = ['hi@hlavezzo.me']

  spec.summary = 'Simple use case objects'
  spec.description = 'Really simple fluxus objects for use cases.'
  spec.homepage = 'https://github.com/Rynaro/fluxus'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
end
