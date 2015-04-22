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
  end

  describe '#installed_versions' do
    it 'should return the installed package version via dpkg-query' do
      pkg_name = 'abcde'
      pkg_versions = ['2.5.3-1']
      pkg_provider = package_provider(pkg_name)
      apt_cache_cmd = apt_cache(pkg_name)

      @fake_capture3.expect(apt_cache_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should return an empty array for missing packages' do
      pkg_name = 'htop'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      apt_cache_cmd = apt_cache(pkg_name)

      @fake_capture3.expect(apt_cache_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should return an empty array for unavailable packages' do
      pkg_name = 'not-a-real-package'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      apt_cache_cmd = apt_cache(pkg_name)

      @fake_capture3.expect(apt_cache_cmd)
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
      pkg_provider = package_provider(pkg_name, pkg_version)
      apt_cmd = apt_get(:install, pkg_name, pkg_version)

      @fake_capture3.expect(apt_cmd)
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
  end
end
