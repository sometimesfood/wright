require File.expand_path('../lib/wright/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Sebastian Boehm']
  gem.email         = ['sebastian@sometimesfood.org']
  gem.description   = 'gem description'
  gem.summary       = 'gem summary'
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(/^bin\//).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(/^(test|spec|features)\//)
  gem.name          = 'wright'
  gem.require_paths = ['lib']
  gem.version       = Wright::VERSION

  gem.add_development_dependency 'minitest', '~> 5.5.1'
  gem.add_development_dependency 'minitest-stub-const', '~> 0.2'
  gem.add_development_dependency 'fakefs', '~> 0.6.4'
  gem.add_development_dependency 'rake', '~> 10.4.2'
  gem.add_development_dependency 'rdoc', '~> 4.2.0'
  gem.add_development_dependency 'simplecov', '~> 0.9.1'
  gem.add_development_dependency 'pry', '~> 0.10.1'
  gem.add_development_dependency 'rubocop', '~> 0.28.0'
end
