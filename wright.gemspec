require File.expand_path('../lib/wright/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Sebastian Boehm']
  gem.email         = ['sebastian@sometimesfood.org']
  gem.license       = 'MIT'
  gem.summary       = 'A lightweight config management tool'
  gem.homepage      = 'https://github.com/sometimesfood/wright'
  gem.description   = <<EOS
Wright is a lightweight configuration management tool.
EOS

  gem.files = Dir['{bin,lib,spec}/**/*',
                  'man/wright.1',
                  'Rakefile',
                  'README.md',
                  'CONTRIBUTING.md',
                  'NEWS.md',
                  'LICENSE'] & `git ls-files -z`.split("\0")

  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'wright'
  gem.require_paths = ['lib']
  gem.version       = Wright::VERSION

  gem.required_ruby_version = '>= 1.9.3'

  unless RUBY_VERSION < '2.0.0'
    gem.add_development_dependency 'mustache', '~> 1.0.2'
  end
  gem.add_development_dependency 'minitest', '~> 5.8.4'
  gem.add_development_dependency 'minitest-stub-const', '~> 0.5'
  gem.add_development_dependency 'fakefs', '~> 0.8.0'
  gem.add_development_dependency 'fakeetc', '~> 0.3.0'
  gem.add_development_dependency 'rake', '~> 12.3.3'
  gem.add_development_dependency 'yard', '~> 0.9.12'
  gem.add_development_dependency 'redcarpet', '~> 3.3.2'
  gem.add_development_dependency 'simplecov', '~> 0.11.2'

  unless ENV.fetch('CONTINUOUS_INTEGRATION', 'false') == 'true'
    gem.add_development_dependency 'rubocop', '~> 0.52.1'
  end
end
