require_relative '../../spec_helper'

require 'wright/provider/group/gnu'
require 'fakeetc'

describe Wright::Provider::Group::Gnu do
  def group_provider(group_name, gid = nil, members = nil, system = false)
    group_resource = OpenStruct.new(name: group_name,
                                    gid: gid,
                                    members: members,
                                    system: system)
    Wright::Provider::Group::Gnu.new(group_resource)
  end

  def gpasswd(group_name, members)
    ['gpasswd', '-M', members.join(','), group_name]
  end

  before(:each) do
    gnu_dir = File.join(File.dirname(__FILE__), 'gnu')
    @fake_capture3 = FakeCapture3.new(gnu_dir)
    @groups = { 'foobar' => { gid: 42, mem: %w(foo bar) },
                'bazqux' => { gid: 43, mem: %w(baz qux) } }
    FakeEtc.add_groups(@groups)
  end

  after(:each) do
    FakeEtc.clear_groups
  end

  describe '#system_group_option' do
    it 'should return the correct system option' do
      resource = OpenStruct.new(name: 'foo')
      group = Wright::Provider::Group::Gnu.new(resource)
      expected = '-r'
      actual = group.send(:system_group_option)
      actual.must_equal expected
    end
  end

  describe '#create_group' do
    it 'should clear member lists for existing groups' do
      group_name = 'foobar'
      gid = @groups[group_name][:gid]
      members = []
      group_provider = group_provider(group_name, gid, members)
      gpasswd_cmd = gpasswd(group_name, members)

      @fake_capture3.expect(gpasswd_cmd)
      @fake_capture3.stub do
        FakeEtc do
          group_provider.create
        end
      end
    end

    it 'should update member lists for existing groups' do
      group_name = 'foobar'
      gid = @groups[group_name][:gid]
      members = %w(user1 user2)
      group_provider = group_provider(group_name, gid, members)
      gpasswd_cmd = gpasswd(group_name, members)

      @fake_capture3.expect(gpasswd_cmd)
      @fake_capture3.stub do
        FakeEtc do
          group_provider.create
        end
      end
    end

    it 'should report errors by gpasswd' do
      user = 'not-a-user'
      members = [user]
      group_name = 'foobar'
      group_provider = group_provider(group_name, nil, members)
      gpasswd_cmd = gpasswd(group_name, members)

      @fake_capture3.expect(gpasswd_cmd)
      @fake_capture3.stub do
        FakeEtc do
          e = -> { group_provider.create }.must_raise RuntimeError
          wright_error = "cannot create group '#{group_name}'"
          gpasswd_error = "gpasswd: user '#{user}' does not exist"
          e.message.must_equal %(#{wright_error}: "#{gpasswd_error}")
        end
      end
    end
  end
end
