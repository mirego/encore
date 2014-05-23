# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'encore/version'

Gem::Specification.new do |spec|
  spec.name          = 'encore'
  spec.version       = Encore::VERSION
  spec.authors       = ['Simon Prévost']
  spec.email         = ['sprevost@mirego.com']
  spec.description   = ''
  spec.summary       = ''
  spec.homepage      = 'https://github.com/mirego/encore'
  spec.license       = 'BSD 3-Clause'

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
end
