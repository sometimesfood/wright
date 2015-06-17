require_relative '../../spec_helper'

require 'wright/provider/package/apt'

describe Wright::Provider::Package::Apt do
  def apt_cache(cmd, pkg_name)
    ['apt-cache', cmd.to_s, pkg_name]
  end

  def apt_get(action, pkg_name, args = {})
    version = args[:version].nil? ? '' : "=#{args[:version]}"
    options = args[:options]
    ['apt-get', '-qy', *options, action.to_s, pkg_name + version]
  end

  def package_provider(pkg_name, args = {})
    properties = { name: pkg_name,
                   version: args[:version],
                   options: args[:options] }
    pkg_resource = OpenStruct.new(properties)
    Wright::Provider::Package::Apt.new(pkg_resource)
  end

  before :each do
    apt_dir = File.join(File.dirname(__FILE__), 'apt')
    env = { 'DEBIAN_FRONTEND' => 'noninteractive' }
    @fake_capture3 = FakeCapture3.new(apt_dir, env)
  end

  describe '#installed_versions' do
    it 'should return the installed package version via dpkg-query' do
      pkg_name = 'abcde'
      pkg_versions = ['2.5.3-1']
      pkg_provider = package_provider(pkg_name)
      apt_cache_cmd = apt_cache(:policy, pkg_name)

      @fake_capture3.expect(apt_cache_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should return an empty array for missing packages' do
      pkg_name = 'htop'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      apt_cache_policy_cmd = apt_cache(:policy, pkg_name)
      apt_cache_showpkg_cmd = apt_cache(:showpkg, pkg_name)

      @fake_capture3.expect(apt_cache_policy_cmd)
      @fake_capture3.expect(apt_cache_showpkg_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should handle virtual packages for which providers are installed' do
      pkg_name = 'linux-image'
      provider_name = 'linux-image-3.2.0-4-amd64'
      pkg_versions = ['virtual']
      pkg_provider = package_provider(pkg_name)
      apt_cache_policy_cmd = apt_cache(:policy, pkg_name)
      apt_cache_showpkg_cmd = apt_cache(:showpkg, pkg_name)
      apt_cache_policy_provider_cmd = apt_cache(:policy, provider_name)

      @fake_capture3.expect(apt_cache_policy_cmd)
      @fake_capture3.expect(apt_cache_showpkg_cmd)
      @fake_capture3.expect(apt_cache_policy_provider_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should handle virtual packages for which no providers are installed' do
      pkg_name = 'dmenu'
      provider_name = 'suckless-tools'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      apt_cache_policy_cmd = apt_cache(:policy, pkg_name)
      apt_cache_showpkg_cmd = apt_cache(:showpkg, pkg_name)
      apt_cache_policy_provider_cmd = apt_cache(:policy, provider_name)
      apt_cache_showpkg_provider_cmd = apt_cache(:showpkg, provider_name)

      @fake_capture3.expect(apt_cache_policy_cmd)
      @fake_capture3.expect(apt_cache_showpkg_cmd)
      @fake_capture3.expect(apt_cache_policy_provider_cmd)
      @fake_capture3.expect(apt_cache_showpkg_provider_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should return an empty array for unavailable packages' do
      pkg_name = 'not-a-real-package'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      apt_cache_policy_cmd = apt_cache(:policy, pkg_name)
      apt_cache_showpkg_cmd = apt_cache(:showpkg, pkg_name)

      @fake_capture3.expect(apt_cache_policy_cmd)
      @fake_capture3.expect(apt_cache_showpkg_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end
  end

  describe '#install_package' do
    it 'should install packages' do
      pkg_name = 'htop'
      pkg_provider = package_provider(pkg_name)
      apt_cmd = apt_get(:install, pkg_name)

      @fake_capture3.expect(apt_cmd)
      @fake_capture3.stub do
        pkg_provider.send(:install_package)
      end
    end

    it 'should install specific package versions' do
      pkg_name = 'abcde'
      pkg_version = '2.5.4-1'
      pkg_provider = package_provider(pkg_name, version: pkg_version)
      apt_cmd = apt_get(:install, pkg_name, version: pkg_version)

      @fake_capture3.expect(apt_cmd)
      @fake_capture3.stub do
        pkg_provider.send(:install_package)
      end
    end

    it 'should pass options to the package manager' do
      pkg_name = 'htop'
      pkg_options = ['--no-install-recommends']
      pkg_provider = package_provider(pkg_name, options: pkg_options)
      apt_cmd = apt_get(:install, pkg_name, options: pkg_options)

      @fake_capture3.expect(apt_cmd, 'apt-get_-qy_install_htop')
      @fake_capture3.stub do
        pkg_provider.send(:install_package)
      end
    end

    it 'should raise exceptions for unknown packages' do
      pkg_name = 'not-a-real-package'
      pkg_provider = package_provider(pkg_name)
      apt_cmd = apt_get(:install, pkg_name)

      @fake_capture3.expect(apt_cmd)
      @fake_capture3.stub do
        e = -> { pkg_provider.send(:install_package) }.must_raise RuntimeError
        wright_error = "cannot install package '#{pkg_name}'"
        apt_error = "E: Unable to locate package #{pkg_name}"
        e.message.must_equal %(#{wright_error}: "#{apt_error}")
      end
    end
  end

  describe '#remove_package' do
    it 'should remove packages' do
      pkg_name = 'abcde'
      pkg_provider = package_provider(pkg_name)
      apt_cmd = apt_get(:remove, pkg_name)

      @fake_capture3.expect(apt_cmd)
      @fake_capture3.stub do
        pkg_provider.send(:remove_package)
      end
    end

    it 'should pass options to the package manager' do
      pkg_name = 'abcde'
      pkg_options = ['--purge']
      pkg_provider = package_provider(pkg_name, options: pkg_options)
      apt_cmd = apt_get(:remove, pkg_name, options: pkg_options)

      @fake_capture3.expect(apt_cmd)
      @fake_capture3.stub do
        pkg_provider.send(:remove_package)
      end
    end
  end
end
