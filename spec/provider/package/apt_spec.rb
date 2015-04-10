require_relative '../../spec_helper'

require 'wright/provider/package/apt'

describe Wright::Provider::Package::Apt do
  def apt_cache(pkg_name)
    ['apt-cache', 'policy', pkg_name]
  end

  def apt_get(action, pkg_name, pkg_version = nil)
    version = pkg_version.nil? ? '' : "=#{pkg_version}"
    ['apt-get', action.to_s, '-qy', pkg_name + version]
  end

  def package_provider(pkg_name, pkg_version = nil)
    pkg_resource = OpenStruct.new(name: pkg_name, version: pkg_version)
    Wright::Provider::Package::Apt.new(pkg_resource)
  end

  before :each do
    apt_dir = File.join(File.dirname(__FILE__), 'apt')
    env = { 'DEBIAN_FRONTEND' => 'noninteractive' }
    @fake_capture3 = FakeCapture3.new(apt_dir, env)
    @install_message = ->(pkg) { "INFO: install package: '#{pkg}'\n" }
    @install_message_dry = lambda do |pkg|
      "INFO: (would) install package: '#{pkg}'\n"
    end
    @install_message_debug = lambda do |pkg|
      "DEBUG: package already installed: '#{pkg}'\n"
    end
    @remove_message = ->(pkg) { "INFO: remove package: '#{pkg}'\n" }
    @remove_message_dry = lambda do |pkg|
      "INFO: (would) remove package: '#{pkg}'\n"
    end
    @remove_message_debug = lambda do |pkg|
      "DEBUG: package already removed: '#{pkg}'\n"
    end
  end

  describe '#installed_versions' do
    it 'should return the installed package version via dpkg-query' do
      pkg_name = 'abcde'
      pkg_versions = ['2.5.3-1']
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should return an empty array for missing packages' do
      pkg_name = 'htop'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should return an empty array for unavailable packages' do
      pkg_name = 'not-a-real-package'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end
  end

  describe '#install' do
    it 'should install packages that are not currently installed' do
      pkg_name = 'htop'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)
      apt_cmd = apt_get(:install, pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.expect(apt_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.install
          pkg_provider.updated?.must_equal true
        end.must_output @install_message.call(pkg_name)
      end
    end

    it 'should not try to install packages that are already installed' do
      pkg_name = 'abcde'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.install
          pkg_provider.updated?.must_equal false
        end.must_output @install_message_debug.call(pkg_name)
      end
    end

    it 'should install package versions that are not currently installed' do
      pkg_name = 'abcde'
      pkg_version = '2.5.4-1'
      pkg_provider = package_provider(pkg_name, pkg_version)
      dpkg_cmd = apt_cache(pkg_name)
      apt_cmd = apt_get(:install, pkg_name, pkg_version)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.expect(apt_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.install
          pkg_provider.updated?.must_equal true
        end.must_output @install_message.call(pkg_name)
      end
    end

    it 'should not try to install package versions already installed' do
      pkg_name = 'abcde'
      pkg_version = '2.5.3-1'
      pkg_provider = package_provider(pkg_name, pkg_version)
      dpkg_cmd = apt_cache(pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.install
          pkg_provider.updated?.must_equal false
        end.must_output @install_message_debug.call(pkg_name)
      end
    end

    it 'should raise exceptions for unknown packages' do
      pkg_name = 'not-a-real-package'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)
      apt_cmd = apt_get(:install, pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.expect(apt_cmd)
      @fake_capture3.stub do
        e = -> { pkg_provider.install }.must_raise RuntimeError
        wright_error = "cannot install package '#{pkg_name}'"
        apt_error = "E: Unable to locate package #{pkg_name}"
        e.message.must_equal %(#{wright_error}: "#{apt_error}")
      end
    end
  end

  describe '#remove' do
    it 'should remove packages that are currently installed' do
      pkg_name = 'abcde'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)
      apt_cmd = apt_get(:remove, pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.expect(apt_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.remove
          pkg_provider.updated?.must_equal true
        end.must_output @remove_message.call(pkg_name)
      end
    end

    it 'should not try to remove packages that are already removed' do
      pkg_name = 'htop'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.remove
          pkg_provider.updated?.must_equal false
        end.must_output @remove_message_debug.call(pkg_name)
      end
    end

    it 'should remove package versions that are currently installed' do
      pkg_name = 'abcde'
      pkg_version = '2.5.3-1'
      pkg_provider = package_provider(pkg_name, pkg_version)
      dpkg_cmd = apt_cache(pkg_name)
      apt_cmd = apt_get(:remove, pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.expect(apt_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.remove
          pkg_provider.updated?.must_equal true
        end.must_output @remove_message.call(pkg_name)
      end
    end

    it 'should not try to remove packages that are already removed' do
      pkg_name = 'htop'
      pkg_version = '2.5.4-1'
      pkg_provider = package_provider(pkg_name, pkg_version)
      dpkg_cmd = apt_cache(pkg_name)

      @fake_capture3.expect(dpkg_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.remove
          pkg_provider.updated?.must_equal false
        end.must_output @remove_message_debug.call(pkg_name)
      end
    end
  end

  describe 'dry_run' do
    it 'should not actually install packages' do
      pkg_name = 'htop'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)

      Wright.dry_run do
        @fake_capture3.expect(dpkg_cmd)
        @fake_capture3.stub do
          lambda do
            reset_logger
            pkg_provider.install
          end.must_output @install_message_dry.call(pkg_name)
        end
      end
    end

    it 'should not try to install packages that are already installed' do
      pkg_name = 'abcde'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)

      Wright.dry_run do
        @fake_capture3.expect(dpkg_cmd)
        @fake_capture3.stub do
          lambda do
            reset_logger
            pkg_provider.install
            pkg_provider.updated?.must_equal false
          end.must_output @install_message_debug.call(pkg_name)
        end
      end
    end

    it 'should not actually remove packages' do
      pkg_name = 'abcde'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)

      Wright.dry_run do
        @fake_capture3.expect(dpkg_cmd)
        @fake_capture3.stub do
          lambda do
            reset_logger
            pkg_provider.remove
          end.must_output @remove_message_dry.call(pkg_name)
        end
      end
    end

    it 'should not try to remove packages that are already removed' do
      pkg_name = 'htop'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = apt_cache(pkg_name)

      Wright.dry_run do
        @fake_capture3.expect(dpkg_cmd)
        @fake_capture3.stub do
          lambda do
            reset_logger
            pkg_provider.remove
            pkg_provider.updated?.must_equal false
          end.must_output @remove_message_debug.call(pkg_name)
        end
      end
    end
  end
end
