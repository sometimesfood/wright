begin
  require 'simplecov'
  if ENV['COVERAGE']
    SimpleCov.start do
      add_filter "/spec/"
    end
  end
rescue LoadError
end

require 'minitest/spec'
require 'minitest/autorun'
