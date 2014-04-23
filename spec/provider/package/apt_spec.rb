require_relative '../../spec_helper'

require 'wright/provider/package/apt'

require 'minitest/mock'
require 'open3'

class FakeProcessStatus
  def initialize(success)
    @success = success
  end

  def success?
    @success
  end
end

FakePackageResource = Struct.new(:name)

def command_output(filename)
  command_stdout = File.read("#{APT_DIR}/#{filename}.stdout")
  command_stderr = File.read("#{APT_DIR}/#{filename}.stderr")
  command_status = File.read("#{APT_DIR}/#{filename}.return").chomp == '0'
  [command_stdout, command_stderr, FakeProcessStatus.new(command_status)]
end

APT_DIR = File.join(File.dirname(__FILE__), 'apt')

CAPTURE3_COMMANDS =
  Dir["#{APT_DIR}/*.stdout"].map { |f| File.basename(f, '.stdout') }

CAPTURE3 =
  Hash[CAPTURE3_COMMANDS.map do |c|
         [c.gsub('_', ' '),
          command_output(c)]
       end]

def dpkg_query(pkg_name)
  "dpkg-query -s #{pkg_name}"
end

def apt_get_install(pkg_name)
  "apt-get install -qy #{pkg_name}"
end

def package_provider(pkg_name)
  pkg_resource = FakePackageResource.new(pkg_name)
  Wright::Provider::Package::Apt.new(pkg_resource)
end

describe Wright::Provider::Package::Apt do
  before :each do
    @env = { 'DEBIAN_FRONTEND' => 'noninteractive' }
    @mock_open3 = Minitest::Mock.new
    @capture3_stub = ->(env, command) { @mock_open3.capture3(env, command) }
    @install_message = ->(pkg) { "INFO: install package: '#{pkg}'\n" }
    @install_message_dry = lambda do |pkg|
      "INFO: (would) install package: '#{pkg}'\n"
    end
    @install_message_debug = lambda do |pkg|
      "DEBUG: package already installed: '#{pkg}'\n"
    end
    #@remove_message = "INFO: remove symlink: '#{name}'\n"
    #@remove_message_dry = "INFO: (would) remove symlink: '#{name}'\n"
    #@remove_message_debug = "DEBUG: symlink already removed: '#{name}'\n"
  end

  describe '#installed_version' do
    it 'should return the installed package version via dpkg-query' do
      pkg_name = 'abcde'
      pkg_version = '2.5.3-1'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = dpkg_query(pkg_name)

      @mock_open3.expect(:capture3, CAPTURE3[dpkg_cmd], [@env, dpkg_cmd])
      Open3.stub :capture3, @capture3_stub do
        pkg_provider.installed_version.must_equal pkg_version
      end
      @mock_open3.verify
    end

    it 'should return nil for missing packages' do
      pkg_name = 'vlc'
      pkg_version = nil
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = dpkg_query(pkg_name)

      @mock_open3.expect(:capture3, CAPTURE3[dpkg_cmd], [@env, dpkg_cmd])
      Open3.stub :capture3, @capture3_stub do
        pkg_provider.installed_version.must_equal pkg_version
      end
      @mock_open3.verify
    end

    it 'should return nil for removed packages' do
      pkg_name = 'htop'
      pkg_version = nil
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = dpkg_query(pkg_name)

      @mock_open3.expect(:capture3, CAPTURE3[dpkg_cmd], [@env, dpkg_cmd])
      Open3.stub :capture3, @capture3_stub do
        pkg_provider.installed_version.must_equal pkg_version
      end
      @mock_open3.verify
    end
  end

  describe '#install' do
    it 'should install packages that are not currently installed' do
      pkg_name = 'htop'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = dpkg_query(pkg_name)
      apt_cmd = apt_get_install(pkg_name)

      @mock_open3.expect(:capture3, CAPTURE3[dpkg_cmd], [@env, dpkg_cmd])
      @mock_open3.expect(:capture3, CAPTURE3[apt_cmd], [@env, apt_cmd])
      Open3.stub :capture3, @capture3_stub do
        lambda do
          reset_logger
          pkg_provider.install
          pkg_provider.updated?.must_equal true
        end.must_output @install_message.call(pkg_name)
      end
      @mock_open3.verify
    end

    it 'should not install packages that are already installed' do
      pkg_name = 'abcde'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = dpkg_query(pkg_name)

      @mock_open3.expect(:capture3, CAPTURE3[dpkg_cmd], [@env, dpkg_cmd])
      Open3.stub :capture3, @capture3_stub do
        lambda do
          reset_logger
          pkg_provider.install
          pkg_provider.updated?.must_equal false
        end.must_output @install_message_debug.call(pkg_name)
      end
      @mock_open3.verify
    end

    it 'should raise exceptions for unknown packages' do
      pkg_name = 'unknown-package'
      pkg_provider = package_provider(pkg_name)
      dpkg_cmd = dpkg_query(pkg_name)
      apt_cmd = apt_get_install(pkg_name)

      @mock_open3.expect(:capture3, CAPTURE3[dpkg_cmd], [@env, dpkg_cmd])
      @mock_open3.expect(:capture3, CAPTURE3[apt_cmd], [@env, apt_cmd])
      Open3.stub :capture3, @capture3_stub do
        e = -> { pkg_provider.install }.must_raise RuntimeError
        wright_error = "cannot install package '#{pkg_name}'"
        apt_error = "E: Unable to locate package #{pkg_name}"
        e.message.must_equal %Q(#{wright_error}: "#{apt_error}")
      end
      @mock_open3.verify
    end

    describe 'dry_run' do
      it 'should not actually install packages' do
        pkg_name = 'htop'
        pkg_provider = package_provider(pkg_name)
        dpkg_cmd = dpkg_query(pkg_name)

        Wright.dry_run do
          @mock_open3.expect(:capture3, CAPTURE3[dpkg_cmd], [@env, dpkg_cmd])
          Open3.stub :capture3, @capture3_stub do
            lambda do
              reset_logger
              pkg_provider.install
            end.must_output @install_message_dry.call(pkg_name)
          end
          @mock_open3.verify
        end
      end
    end
  end
end
