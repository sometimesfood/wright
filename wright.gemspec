require File.expand_path('../lib/wright/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Sebastian Boehm']
  gem.email         = ['sebastian@sometimesfood.org']
  gem.description   = %q{gem description}
  gem.summary       = %q{gem summary}
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'wright'
  gem.require_paths = ['lib']
  gem.version       = Wright::VERSION

  gem.add_development_dependency 'minitest', '~> 5.3.3'
  gem.add_development_dependency 'fakefs', '~> 0.5.2'
  gem.add_development_dependency 'rake', '~> 10.2.2'
  gem.add_development_dependency 'rdoc', '~> 4.1.1'
  gem.add_development_dependency 'simplecov', '~> 0.7.1'
  gem.add_development_dependency 'rubocop'
end
