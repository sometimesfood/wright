print 'loaded shebang.rb'
class WrightDSLMissing < StandardError; end
raise WrightDSLMissing unless respond_to? :package
