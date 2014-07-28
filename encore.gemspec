# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'encore/version'

Gem::Specification.new do |spec|
  spec.name          = 'encore'
  spec.version       = Encore::VERSION
  spec.authors       = ['Simon Prévost']
  spec.email         = ['sprevost@mirego.com']
  spec.description   = 'Encore provides serializers and persisters to build JSON API-compliant Web services with Ruby on Rails.'
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/mirego/encore'
  spec.license       = 'BSD 3-Clause'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '>= 4.0.0'
  spec.add_dependency 'activerecord', '>= 4.0.0'
  spec.add_dependency 'active_model_serializers', '~> 0.8.0'
  spec.add_dependency 'kaminari', '>= 0.15'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'sqlite3', '>= 1.3.8', '< 1.4'
  spec.add_development_dependency 'rubocop', '0.22'
  spec.add_development_dependency 'phare'
end
