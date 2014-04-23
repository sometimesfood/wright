require_relative '../spec_helper'

require 'wright/provider'
require 'wright/provider/package'

describe Wright::Provider::Package do
  describe '#uptodate?' do
    it 'should return the correct status for all available actions' do
      pkg_resource = OpenStruct.new(name: 'foo')
      pkg_provider = Wright::Provider::Package.new(pkg_resource)

      def pkg_provider.installed_version
        42
      end
      pkg_provider.uptodate?(:install).must_equal true
      pkg_provider.uptodate?(:remove).must_equal false

      def pkg_provider.installed_version
        nil
      end
      pkg_provider.uptodate?(:install).must_equal false
      pkg_provider.uptodate?(:remove).must_equal true
    end

    it 'should raise exceptions for invalid actions' do
      pkg_resource = OpenStruct.new(name: 'foo')
      pkg_provider = Wright::Provider::Package.new(pkg_resource)
      e = -> { pkg_provider.uptodate?(:foobarbaz) }.must_raise ArgumentError
      e.message.must_equal "invalid action 'foobarbaz'"
    end
  end
end
