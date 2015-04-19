require_relative '../spec_helper'

require 'wright/provider'
require 'wright/provider/package'

describe Wright::Provider::Package do
  describe '#uptodate?' do
    before(:each) do
      Wright::Provider::Package.send(:public, :uptodate?)
    end

    after(:each) do
      Wright::Provider::Package.send(:private, :uptodate?)
    end

    it 'should return the correct status' do
      pkg_resource = OpenStruct.new(name: 'foo')
      pkg_provider = Wright::Provider::Package.new(pkg_resource)

      def pkg_provider.installed_versions
        ['4.2']
      end
      pkg_provider.uptodate?(:install).must_equal true
      pkg_provider.uptodate?(:remove).must_equal false

      def pkg_provider.installed_versions
        []
      end
      pkg_provider.uptodate?(:install).must_equal false
      pkg_provider.uptodate?(:remove).must_equal true
    end

    it 'should return the correct status when given a specific version' do
      pkg_resource = OpenStruct.new(name: 'foo', version: '4.3')
      pkg_provider = Wright::Provider::Package.new(pkg_resource)

      def pkg_provider.installed_versions
        ['4.2']
      end
      pkg_provider.uptodate?(:install).must_equal false
      pkg_provider.uptodate?(:remove).must_equal true

      def pkg_provider.installed_versions
        []
      end
      pkg_provider.uptodate?(:install).must_equal false
      pkg_provider.uptodate?(:remove).must_equal true

      def pkg_provider.installed_versions
        ['4.3']
      end
      pkg_provider.uptodate?(:install).must_equal true
      pkg_provider.uptodate?(:remove).must_equal false
    end

    it 'should raise exceptions for invalid actions' do
      pkg_resource = OpenStruct.new(name: 'foo')
      pkg_provider = Wright::Provider::Package.new(pkg_resource)
      e = -> { pkg_provider.uptodate?(:foobarbaz) }.must_raise ArgumentError
      e.message.must_equal "invalid action 'foobarbaz'"
    end
  end

  describe '#install' do
    before(:each) do
      pkg = 'foo'
      @resource = OpenStruct.new(name: pkg)
      @package = Wright::Provider::Package.new(@resource)
      @mock_provider = Minitest::Mock.new
      @installed_versions_stub = -> { @mock_provider.installed_versions }
      @install_package_stub = -> { @mock_provider.install_package }

      @install_message = "INFO: install package: '#{pkg}'\n"
      @install_message_dry = "INFO: (would) install package: '#{pkg}'\n"
      @install_message_debug = "DEBUG: package already installed: '#{pkg}'\n"
    end

    it 'should install packages that are not yet installed' do
      @mock_provider.expect(:installed_versions, [])
      @mock_provider.expect(:install_package, true)

      @package.stub(:installed_versions, @installed_versions_stub) do
        @package.stub(:install_package, @install_package_stub) do
          lambda do
            reset_logger
            @package.install
            @package.updated?.must_equal true
          end.must_output @install_message
        end
      end
      @mock_provider.verify
    end

    it 'should not try to install packages that already installed' do
      @mock_provider.expect(:installed_versions, ['1.2.3'])

      @package.stub(:installed_versions, @installed_versions_stub) do
        @package.stub(:install_package, @install_package_stub) do
          lambda do
            reset_logger
            @package.install
            @package.updated?.must_equal false
          end.must_output @install_message_debug
        end
      end
      @mock_provider.verify
    end

    it 'should not try to install packages in dry-run mode' do
      @mock_provider.expect(:installed_versions, [])

      @package.stub(:installed_versions, @installed_versions_stub) do
        lambda do
          reset_logger
          Wright.dry_run { @package.install }
          @package.updated?.must_equal true
        end.must_output @install_message_dry
      end
      @mock_provider.verify
    end
  end

  describe '#remove' do
    before(:each) do
      pkg = 'foo'
      @resource = OpenStruct.new(name: pkg)
      @package = Wright::Provider::Package.new(@resource)
      @mock_provider = Minitest::Mock.new
      @installed_versions_stub = -> { @mock_provider.installed_versions }
      @remove_package_stub = -> { @mock_provider.remove_package }

      @remove_message = "INFO: remove package: '#{pkg}'\n"
      @remove_message_dry = "INFO: (would) remove package: '#{pkg}'\n"
      @remove_message_debug = "DEBUG: package already removed: '#{pkg}'\n"
    end

    it 'should remove packages that are currently installed' do
      @mock_provider.expect(:installed_versions, ['1.2.3'])
      @mock_provider.expect(:remove_package, true)

      @package.stub(:installed_versions, @installed_versions_stub) do
        @package.stub(:remove_package, @remove_package_stub) do
          lambda do
            reset_logger
            @package.remove
            @package.updated?.must_equal true
          end.must_output @remove_message
        end
      end
      @mock_provider.verify
    end

    it 'should not try to remove packages that are already removed' do
      @mock_provider.expect(:installed_versions, [])

      @package.stub(:installed_versions, @installed_versions_stub) do
        @package.stub(:remove_package, @remove_package_stub) do
          lambda do
            reset_logger
            @package.remove
            @package.updated?.must_equal false
          end.must_output @remove_message_debug
        end
      end
      @mock_provider.verify
    end

    it 'should not try to remove packages in dry-run mode' do
      @mock_provider.expect(:installed_versions, ['1.2.3'])

      @package.stub(:installed_versions, @installed_versions_stub) do
        @package.stub(:remove_package, @remove_package_stub) do
          lambda do
            reset_logger
            Wright.dry_run { @package.remove }
            @package.updated?.must_equal true
          end.must_output @remove_message_dry
        end
      end
      @mock_provider.verify
    end
  end

  describe '#installed_versions' do
    it 'should raise an exception' do
      resource = OpenStruct.new(name: 'foo')
      provider = Wright::Provider::Package.new(resource)
      -> { provider.installed_versions }.must_raise(NotImplementedError)
    end
  end

  describe '#install_package' do
    it 'should raise an exception' do
      resource = OpenStruct.new(name: 'foo')
      provider = Wright::Provider::Package.new(resource)
      -> { provider.send(:install_package) }.must_raise(NotImplementedError)
    end
  end

  describe '#remove_package' do
    it 'should raise an exception' do
      resource = OpenStruct.new(name: 'foo')
      provider = Wright::Provider::Package.new(resource)
      -> { provider.send(:remove_package) }.must_raise(NotImplementedError)
    end
  end
end
