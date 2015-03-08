require_relative '../../spec_helper'

require 'wright/provider/package/homebrew'

describe Wright::Provider::Package::Homebrew do
  def brew(action, pkg_name)
    options = action == :info ? ['info', '--json=v1'] : [action.to_s]
    ['brew', *options, pkg_name]
  end

  def package_provider(pkg_name, pkg_version = nil)
    pkg_resource = OpenStruct.new(name: pkg_name, version: pkg_version)
    Wright::Provider::Package::Homebrew.new(pkg_resource)
  end

  before :each do
    homebrew_dir = File.join(File.dirname(__FILE__), 'homebrew')
    env = {}
    @fake_capture3 = FakeCapture3.new(homebrew_dir, env)
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
    @version_warning = lambda do |pkg, version|
      "WARN: ignoring package version: '#{pkg} (#{version})'"
    end
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

  describe '#install' do
    it 'should install packages that are not currently installed' do
      pkg_name = 'cd-discid'
      pkg_provider = package_provider(pkg_name)
      brew_info_cmd = brew(:info, pkg_name)
      brew_install_cmd = brew(:install, pkg_name)

      @fake_capture3.expect(brew_info_cmd)
      @fake_capture3.expect(brew_install_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.install
          pkg_provider.updated?.must_equal true
        end.must_output @install_message.call(pkg_name)
      end
    end

    it 'should not try to install packages that are already installed' do
      pkg_name = 'lame'
      pkg_provider = package_provider(pkg_name)
      brew_info_cmd = brew(:info, pkg_name)

      @fake_capture3.expect(brew_info_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.install
          pkg_provider.updated?.must_equal false
        end.must_output @install_message_debug.call(pkg_name)
      end
    end

    it 'should output a warning when specifying a package version' do
      pkg_name = 'cd-discid'
      pkg_version = '1.1'
      pkg_provider = package_provider(pkg_name, pkg_version)
      brew_info_cmd = brew(:info, pkg_name)
      brew_install_cmd = brew(:install, pkg_name)

      install_message_with_warning =
        @install_message.call(pkg_name) +
        @version_warning.call(pkg_name, pkg_version) + "\n"

      @fake_capture3.expect(brew_info_cmd)
      @fake_capture3.expect(brew_install_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.install
          pkg_provider.updated?.must_equal true
        end.must_output install_message_with_warning
      end
    end

    it 'should raise exceptions for unavailable packages' do
      pkg_name = 'not-a-real-package'
      pkg_provider = package_provider(pkg_name)
      brew_info_cmd = brew(:info, pkg_name)
      brew_install_cmd = brew(:install, pkg_name)

      @fake_capture3.expect(brew_info_cmd)
      @fake_capture3.expect(brew_install_cmd)
      @fake_capture3.stub do
        e = -> { pkg_provider.install }.must_raise RuntimeError
        wright_error = "cannot install package '#{pkg_name}'"
        brew_error = "Error: No available formula for #{pkg_name} "
        e.message.must_equal %(#{wright_error}: "#{brew_error}")
      end
    end
  end

  describe '#remove' do
    it 'should remove packages that are currently installed' do
      pkg_name = 'lame'
      pkg_provider = package_provider(pkg_name)
      brew_info_cmd = brew(:info, pkg_name)
      brew_uninstall_cmd = brew(:uninstall, pkg_name)

      @fake_capture3.expect(brew_info_cmd)
      @fake_capture3.expect(brew_uninstall_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.remove
          pkg_provider.updated?.must_equal true
        end.must_output @remove_message.call(pkg_name)
      end
    end

    it 'should not try to remove packages that are already removed' do
      pkg_name = 'cd-discid'
      pkg_provider = package_provider(pkg_name)
      brew_info_cmd = brew(:info, pkg_name)

      @fake_capture3.expect(brew_info_cmd)
      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.remove
          pkg_provider.updated?.must_equal false
        end.must_output @remove_message_debug.call(pkg_name)
      end
    end

    it 'should remove package versions that are currently installed' do
      pkg_name = 'lame'
      pkg_version = '3.99.5'
      pkg_provider = package_provider(pkg_name, pkg_version)
      brew_info_cmd = brew(:info, pkg_name)
      brew_uninstall_cmd = brew(:uninstall, pkg_name)

      @fake_capture3.expect(brew_info_cmd)
      @fake_capture3.expect(brew_uninstall_cmd)

      @fake_capture3.stub do
        lambda do
          reset_logger
          pkg_provider.remove
          pkg_provider.updated?.must_equal true
        end.must_output @remove_message.call(pkg_name)
      end
    end
  end

  describe 'dry_run' do
    it 'should not actually install packages' do
      pkg_name = 'cd-discid'
      pkg_provider = package_provider(pkg_name)
      brew_cmd = brew(:info, pkg_name)

      Wright.dry_run do
        @fake_capture3.expect(brew_cmd)
        @fake_capture3.stub do
          lambda do
            reset_logger
            pkg_provider.install
          end.must_output @install_message_dry.call(pkg_name)
        end
      end
    end

    it 'should not try to install packages that are already installed' do
      pkg_name = 'lame'
      pkg_provider = package_provider(pkg_name)
      brew_cmd = brew(:info, pkg_name)

      Wright.dry_run do
        @fake_capture3.expect(brew_cmd)
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
      pkg_name = 'lame'
      pkg_provider = package_provider(pkg_name)
      brew_cmd = brew(:info, pkg_name)

      Wright.dry_run do
        @fake_capture3.expect(brew_cmd)
        @fake_capture3.stub do
          lambda do
            reset_logger
            pkg_provider.remove
          end.must_output @remove_message_dry.call(pkg_name)
        end
      end
    end

    it 'should not try to remove packages that are already removed' do
      pkg_name = 'cd-discid'
      pkg_provider = package_provider(pkg_name)
      brew_cmd = brew(:info, pkg_name)

      Wright.dry_run do
        @fake_capture3.expect(brew_cmd)
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
