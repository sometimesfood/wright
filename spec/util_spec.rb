require_relative 'spec_helper'

require 'minitest/stub_const'
require 'wright/util'

def stub_os(target_os)
  RbConfig.stub_const(:CONFIG, 'target_os' => target_os) do
    yield
  end
end

describe Wright::Util do
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
        end
      end
    end

    it 'should detect other operating systems' do
      stub_os('and now for something completely different') do
        Wright::Util.os_family.must_equal 'other'
      end
    end
  end
end
