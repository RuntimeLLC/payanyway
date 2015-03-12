# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'payanyway/version'

Gem::Specification.new do |spec|
  spec.name          = 'payanyway'
  spec.version       = Payanyway::VERSION.dup
  spec.authors       = ['ssnikolay']
  spec.email         = ['ssnikolay@gmail.com']
  spec.summary       = 'simple gem for payanyway payment gateway'
  spec.description   = 'simple gem for payanyway payment gateway'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '>= 3.2.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pumper'
end
