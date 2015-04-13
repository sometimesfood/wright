require_relative 'spec_helper'

require 'minitest/stub_const'
require 'wright/util'

describe Wright::Util do
  def stub_os(target_os)
    RbConfig.stub_const(:CONFIG, 'target_os' => target_os) do
      yield
    end
  end

  def without_bundler
    if defined?(Bundler)
      Object.stub_remove_const(:Bundler) { yield }
    else
      yield
    end
  end

  def with_bundler
    if defined?(Bundler)
      yield
    else
      fake_bundler = Class.new
      def fake_bundler.with_clean_env; end
      Object.stub_const(:Bundler, fake_bundler) { yield }
    end
  end

  describe 'filename_to_classname' do
    it 'should convert filenames to class names' do
      classname = Wright::Util.filename_to_classname('foo_bar/baz')
      classname.must_equal 'FooBar::Baz'
    end
  end

  describe 'class_to_resource_name' do
    it 'should convert classes to resource names' do
      resource_name = Wright::Util.class_to_resource_name(Object)
      resource_name.must_equal 'object'
    end
  end

  describe 'os_family' do
    before(:each) do
      @debian_os_release = <<EOS
PRETTY_NAME="Debian GNU/Linux 7 (wheezy)"
NAME="Debian GNU/Linux"
VERSION_ID="7"
VERSION="7 (wheezy)"
ID=debian
ANSI_COLOR="1;31"
HOME_URL="http://www.debian.org/"
SUPPORT_URL="http://www.debian.org/support/"
BUG_REPORT_URL="http://bugs.debian.org/"
EOS
      @ubuntu_os_release = <<EOS
NAME="Ubuntu"
VERSION="12.04.4 LTS, Precise Pangolin"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu precise (12.04.4 LTS)"
VERSION_ID="12.04"
EOS
      @centos_os_release = <<EOS
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"
EOS
    end

    after(:each) { FakeFS::FileSystem.clear }

    it 'should detect MacOS X' do
      stub_os('darwin13') do
        Wright::Util.os_family.must_equal 'macosx'
      end
    end

    it 'should detect GNU/Linux distributions' do
      stub_os('linux') do
        FakeFS do
          FileUtils.mkdir('/etc')
          FileUtils.touch('/etc/os-release')
          Wright::Util.os_family.must_equal 'linux'

          File.write('/etc/os-release', @debian_os_release)
          Wright::Util.os_family.must_equal 'debian'

          File.write('/etc/os-release', @ubuntu_os_release)
          Wright::Util.os_family.must_equal 'debian'

          File.write('/etc/os-release', @centos_os_release)
          Wright::Util.os_family.must_equal 'rhel'
        end
      end
    end

    it 'should detect other operating systems' do
      stub_os('and now for something completely different') do
        Wright::Util.os_family.must_equal 'other'
      end
    end
  end

  describe 'bundler_clean_env' do
    it 'should call a block when not using bundler' do
      mock = Minitest::Mock.new

      mock.expect(:inside_block, [])
      without_bundler do
        Wright::Util.bundler_clean_env { mock.inside_block }
      end
      mock.verify
    end

    it 'should call a block using Bundler.with_clean_env when using bundler' do
      mock = Minitest::Mock.new
      with_clean_env_stub = -> { mock.with_clean_env }

      mock.expect(:with_clean_env, [])
      mock.expect(:inside_block, [])
      with_bundler do
        Bundler.stub(:with_clean_env, with_clean_env_stub) do
          Wright::Util.bundler_clean_env { mock.inside_block }
        end
      end
      mock.verify
    end
  end
end
