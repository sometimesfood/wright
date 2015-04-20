def codeclimate?
  ENV['CODECLIMATE_REPO_TOKEN']
end

def simplecov?
  ENV['COVERAGE']
end

def coverage?
  simplecov? || codeclimate?
end

def measure_coverage
  require 'simplecov'
  formatters = []
  formatters << SimpleCov::Formatter::HTMLFormatter if simplecov?

  if codeclimate?
    require 'codeclimate-test-reporter'
    formatters << CodeClimate::TestReporter::Formatter
  end

  ignored_directories = ['/spec/', '/vendor/', '/.bundle/']
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
  SimpleCov.start { add_filter(ignored_directories) }
end
