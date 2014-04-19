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

CAPTURE3 = {
  'dpkg-query -s abcde' => command_output('dpkg-query.abcde'),
  'dpkg-query -s htop' => command_output('dpkg-query.htop'),
  'dpkg-query -s vlc' => command_output('dpkg-query.vlc')
}

describe Wright::Provider::Package::Apt do
  before :each do
    @mock_open3 = Minitest::Mock.new
    @capture3_stub = ->(command) { @mock_open3.capture3(command) }
  end

  describe '#installed_version' do
    it 'should return the installed package version via dpkg-query' do
      pkg_name = 'abcde'
      pkg_version = '2.5.3-1'
      pkg_resource = FakePackageResource.new(pkg_name)
      pkg_provider = Wright::Provider::Package::Apt.new(pkg_resource)
      command =  "dpkg-query -s #{pkg_name}"

      @mock_open3.expect(:capture3, CAPTURE3[command], [command])
      Open3.stub :capture3, @capture3_stub do
        pkg_provider.installed_version.must_equal pkg_version
      end
      @mock_open3.verify
    end

    it 'should return nil for missing packages' do
      pkg_name = 'vlc'
      pkg_version = nil
      pkg_resource = FakePackageResource.new(pkg_name)
      pkg_provider = Wright::Provider::Package::Apt.new(pkg_resource)
      command =  "dpkg-query -s #{pkg_name}"

      @mock_open3.expect(:capture3, CAPTURE3[command], [command])
      Open3.stub :capture3, @capture3_stub do
        pkg_provider.installed_version.must_equal pkg_version
      end
      @mock_open3.verify
    end

    it 'should return nil for removed packages' do
      pkg_name = 'htop'
      pkg_version = nil
      pkg_resource = FakePackageResource.new(pkg_name)
      pkg_provider = Wright::Provider::Package::Apt.new(pkg_resource)
      command =  "dpkg-query -s #{pkg_name}"

      @mock_open3.expect(:capture3, CAPTURE3[command], [command])
      Open3.stub :capture3, @capture3_stub do
        pkg_provider.installed_version.must_equal pkg_version
      end
      @mock_open3.verify
    end
  end
end
