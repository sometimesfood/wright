require_relative '../../spec_helper'

require 'wright/provider/package/homebrew'

describe Wright::Provider::Package::Homebrew do
  def brew(action, pkg_name, args = {})
    action_args = action == :info ? ['info', '--json=v1'] : [action.to_s]
    ['brew', *action_args, *args[:options], pkg_name]
  end

  def package_provider(pkg_name, args = {})
    properties = { name: pkg_name,
                   version: args[:version],
                   options: args[:options] }
    pkg_resource = OpenStruct.new(properties)
    Wright::Provider::Package::Homebrew.new(pkg_resource)
  end

  before :each do
    homebrew_dir = File.join(File.dirname(__FILE__), 'homebrew')
    @fake_capture3 = FakeCapture3.new(homebrew_dir)
  end

  describe '#installed_versions' do
    it 'should return the installed package version via brew info' do
      pkg_name = 'lame'
      pkg_versions = ['3.99.5']
      pkg_provider = package_provider(pkg_name)
      brew_cmd = brew(:info, pkg_name)

      @fake_capture3.expect(brew_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should return an empty array for uninstalled packages' do
      pkg_name = 'cd-discid'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      brew_cmd = brew(:info, pkg_name)

      @fake_capture3.expect(brew_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should return an empty array for unavailable packages' do
      pkg_name = 'not-a-real-package'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      brew_cmd = brew(:info, pkg_name)

      @fake_capture3.expect(brew_cmd)
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end
  end

  describe '#install_package' do
    it 'should install packages' do
      pkg_name = 'cd-discid'
      pkg_provider = package_provider(pkg_name)
      brew_install_cmd = brew(:install, pkg_name)

      @fake_capture3.expect(brew_install_cmd)
      @fake_capture3.stub do
        pkg_provider.send(:install_package)
      end
    end

    it 'should output a warning when specifying a package version' do
      pkg_name = 'cd-discid'
      pkg_version = '1.1'
      pkg_provider = package_provider(pkg_name, version: pkg_version)
      brew_install_cmd = brew(:install, pkg_name)
      version_warning =
        "WARN: ignoring package version: '#{pkg_name} (#{pkg_version})'\n"

      @fake_capture3.expect(brew_install_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.send(:install_package)
        end.must_output version_warning
      end
    end

    it 'should pass options to the package manager' do
      pkg_name = 'gnu-units'
      pkg_options = '--with-default-names'
      pkg_provider = package_provider(pkg_name, options: pkg_options)
      brew_install_cmd = brew(:install, pkg_name, options: pkg_options)

      @fake_capture3.expect(brew_install_cmd)
      @fake_capture3.stub do
        pkg_provider.send(:install_package)
      end
    end

    it 'should raise exceptions for unavailable packages' do
      pkg_name = 'not-a-real-package'
      pkg_provider = package_provider(pkg_name)
      brew_install_cmd = brew(:install, pkg_name)

      @fake_capture3.expect(brew_install_cmd)
      @fake_capture3.stub do
        e = -> { pkg_provider.send(:install_package) }.must_raise RuntimeError
        wright_error = "cannot install package '#{pkg_name}'"
        brew_error = "Error: No available formula for #{pkg_name} "
        e.message.must_equal %(#{wright_error}: "#{brew_error}")
      end
    end
  end

  describe '#remove_package' do
    it 'should remove packages' do
      pkg_name = 'lame'
      pkg_provider = package_provider(pkg_name)
      brew_uninstall_cmd = brew(:uninstall, pkg_name)

      @fake_capture3.expect(brew_uninstall_cmd)
      @fake_capture3.stub do
        pkg_provider.send(:remove_package)
      end
    end

    it 'should pass options to the package manager' do
      pkg_name = 'lame'
      pkg_options = ['--force']
      pkg_provider = package_provider(pkg_name, options: pkg_options)
      brew_uninstall_cmd = brew(:uninstall, pkg_name, options: pkg_options)

      @fake_capture3.expect(brew_uninstall_cmd)
      @fake_capture3.stub do
        pkg_provider.send(:remove_package)
      end
    end
  end
end
