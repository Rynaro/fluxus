# frozen_string_literal: true

require_relative 'lib/fluxus/version'

Gem::Specification.new do |spec|
  spec.name = 'fluxus'
  spec.version = Fluxus::VERSION
  spec.authors = ['Henrique Aparecido Lavezzo']
  spec.email = ['hi@hlavezzo.me']

  spec.summary = 'Simple Ruby objects for use case wrapping'
  spec.description = 'Fluxus is a simple, dependencyless, and extensible use-case wrapper for your Ruby code.'
  spec.homepage = 'https://github.com/Rynaro/fluxus'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage
  }

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
