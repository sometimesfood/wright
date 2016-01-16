require_relative '../../spec_helper'

require 'wright/provider/package/openbsd'

describe Wright::Provider::Package::Openbsd do
  def pkg_info(pkg_name)
    ['pkg_info', '-e', "#{pkg_name}->0"]
  end

  def pkg_add(pkg_name, args = {})
    version = args[:version].nil? ? '' : "-#{args[:version]}"
    options = args[:options]
    ['pkg_add', *options, pkg_name + version]
  end

  def pkg_delete(pkg_name, args = {})
    options = args[:options]
    ['pkg_delete', *options, pkg_name]
  end

  def package_provider(pkg_name, args = {})
    properties = { name: pkg_name,
                   version: args[:version],
                   options: args[:options] }
    pkg_resource = OpenStruct.new(properties)
    Wright::Provider::Package::Openbsd.new(pkg_resource)
  end

  before :each do
    openbsd_dir = File.join(File.dirname(__FILE__), 'openbsd')
    @fake_capture3 = FakeCapture3.new(openbsd_dir)
  end

  describe '#installed_versions' do
    it 'should return the installed package version via pkg_info' do
      pkg_name = 'ruby'
      pkg_versions = ['2.1.6p0']
      pkg_provider = package_provider(pkg_name)
      pkg_info_cmd = pkg_info(pkg_name)

      @fake_capture3.expect(pkg_info_cmd, 'pkg_info_ruby')
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should return an empty array for missing packages' do
      pkg_name = 'wget'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      pkg_info_cmd = pkg_info(pkg_name)

      @fake_capture3.expect(pkg_info_cmd, 'pkg_info_wget')
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end
  end

  describe '#install_package' do
    it 'should install packages' do
      pkg_name = 'nano'
      pkg_provider = package_provider(pkg_name)
      pkg_add_cmd = pkg_add(pkg_name)

      @fake_capture3.expect(pkg_add_cmd)
      @fake_capture3.stub do
        pkg_provider.send(:install_package)
      end
    end

    it 'should install specific package versions' do
      pkg_name = 'nano'
      pkg_version = '2.4.2'
      pkg_provider = package_provider(pkg_name, version: pkg_version)
      pkg_add_cmd = pkg_add(pkg_name, version: pkg_version)

      @fake_capture3.expect(pkg_add_cmd, 'pkg_add_nano')
      @fake_capture3.stub do
        pkg_provider.send(:install_package)
      end
    end

    it 'should pass options to the package manager' do
      pkg_name = 'nano'
      pkg_options = ['-D', 'repair']
      pkg_provider = package_provider(pkg_name, options: pkg_options)
      pkg_add_cmd = pkg_add(pkg_name, options: pkg_options)

      @fake_capture3.expect(pkg_add_cmd, 'pkg_add_nano')
      @fake_capture3.stub do
        pkg_provider.send(:install_package)
      end
    end

    it 'should raise exceptions for unknown packages' do
      pkg_name = 'not-a-real-package'
      pkg_provider = package_provider(pkg_name)
      pkg_add_cmd = pkg_add(pkg_name)

      @fake_capture3.expect(pkg_add_cmd)
      @fake_capture3.stub do
        e = -> { pkg_provider.send(:install_package) }.must_raise RuntimeError
        wright_error = "cannot install package '#{pkg_name}'"
        pkg_add_error = "Can't find #{pkg_name}"
        e.message.must_equal %(#{wright_error}: "#{pkg_add_error}")
      end
    end
  end

  describe '#remove_package' do
    it 'should remove packages' do
      pkg_name = 'vim'
      pkg_provider = package_provider(pkg_name)
      pkg_delete_cmd = pkg_delete(pkg_name)

      @fake_capture3.expect(pkg_delete_cmd)
      @fake_capture3.stub do
        pkg_provider.send(:remove_package)
      end
    end

    it 'should pass options to the package manager' do
      pkg_name = 'vim'
      pkg_options = ['-a']
      pkg_provider = package_provider(pkg_name, options: pkg_options)
      pkg_delete_cmd = pkg_delete(pkg_name, options: pkg_options)

      @fake_capture3.expect(pkg_delete_cmd, 'pkg_delete_vim')
      @fake_capture3.stub do
        pkg_provider.send(:remove_package)
      end
    end
  end
end
