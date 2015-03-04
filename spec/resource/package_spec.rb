require_relative '../spec_helper'

require 'wright/resource/package'

describe Wright::Resource::Package do
  before(:each) do
    @package = Wright::Resource::Package.new('foo')
    @provider = Minitest::Mock.new
    @package.instance_variable_set(:@provider, @provider)
  end

  describe '#installed_versions' do
    it 'should ask the provider for installed versions' do
      @provider.expect(:installed_versions, nil)
      @package.installed_versions
      @provider.verify
    end
  end

  describe '#install' do
    it 'should ask the provider to install the package' do
      @provider.expect(:install, nil)
      @provider.expect(:updated?, true)
      @package.install
      @provider.verify
    end
  end

  describe '#remove' do
    it 'should ask the provider to remove the package' do
      @provider.expect(:remove, nil)
      @provider.expect(:updated?, true)
      @package.remove
      @provider.verify
    end
  end
end
