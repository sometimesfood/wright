require_relative '../../spec_helper'

require 'wright/provider/package/yum'

describe Wright::Provider::Package::Yum do
  def rpm_q(pkg_name)
    %W(rpm -q #{pkg_name} --qf %{VERSION}-%{RELEASE})
  end

  def package_provider(pkg_name, pkg_version = nil)
    pkg_resource = OpenStruct.new(name: pkg_name, version: pkg_version)
    Wright::Provider::Package::Yum.new(pkg_resource)
  end

  before :each do
    yum_dir = File.join(File.dirname(__FILE__), 'yum')
    @fake_capture3 = FakeCapture3.new(yum_dir)
  end

  describe '#installed_versions' do
    it 'should return the installed package version via brew info' do
      pkg_name = 'zsh'
      pkg_versions = ['5.0.2-7.el7_1.1']
      pkg_provider = package_provider(pkg_name)
      rpm_q_cmd = rpm_q(pkg_name)

      @fake_capture3.expect(rpm_q_cmd, 'rpm_-q_zsh')
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end

    it 'should return an empty array for uninstalled packages' do
      pkg_name = 'httpd'
      pkg_versions = []
      pkg_provider = package_provider(pkg_name)
      rpm_q_cmd = rpm_q(pkg_name)

      @fake_capture3.expect(rpm_q_cmd, 'rpm_-q_httpd')
      @fake_capture3.stub do
        pkg_provider.installed_versions.must_equal pkg_versions
      end
    end
  end
end
