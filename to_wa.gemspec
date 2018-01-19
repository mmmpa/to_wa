
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'to_wa/version'

Gem::Specification.new do |spec|
  spec.name          = 'to_wa'
  spec.version       = ToWa::VERSION
  spec.authors       = ['mmmpa']
  spec.email         = ['mmmpa.mmmpa@gmail.com']

  spec.summary       = 'to where arel'
  spec.description   = 'to where arel'
  spec.homepage      = 'http://mmmpa.net'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'mysql2'
  spec.add_development_dependency 'onkcop'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
