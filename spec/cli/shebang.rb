print 'loaded shebang.rb'
class WrightDSLMissing < StandardError; end
fail WrightDSLMissing unless respond_to? :package
