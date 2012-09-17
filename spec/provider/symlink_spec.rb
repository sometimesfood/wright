require_relative '../spec_helper'

require 'wright/provider/symlink'
require 'fileutils'

describe Wright::Provider::Symlink do
  before(:each) do
    @link_resource = Object.new
    def @link_resource.to; 'foo'; end
    def @link_resource.name; 'bar'; end
  end

  after(:each) do
    FakeFS::FileSystem.clear
  end

  describe '#updated?' do
    it 'should return the update status if a link was created' do
      FakeFS do
        link = Wright::Provider::Symlink.new(@link_resource)
        link.create!
        assert link.updated?
      end
    end

    it 'should return the update status if a link was not created' do
      FakeFS do
        link = Wright::Provider::Symlink.new(@link_resource)
        FileUtils.ln_sf(@link_resource.to, @link_resource.name)
        link.create!
        assert !link.updated?

        FileUtils.rm(@link_resource.name)
        FileUtils.touch(@link_resource.name)
        proc { link.create! }.must_raise Errno::EEXIST
        assert !link.updated?
      end
    end

    it 'should return the update status if a link was changed' do
      FakeFS do
        FileUtils.ln_sf('old-source', @link_resource.name)
        link = Wright::Provider::Symlink.new(@link_resource)
        link.create!
        assert link.updated?
      end
    end

    it 'should return the update status if a link was not changed' do
      FakeFS do
        link = Wright::Provider::Symlink.new(@link_resource)
        FileUtils.ln_sf(@link_resource.to, @link_resource.name)
        link.create!
        assert !link.updated?
      end
    end

    it 'should return the update status if a link was removed' do
      FakeFS do
        link = Wright::Provider::Symlink.new(@link_resource)
        FileUtils.ln_sf(@link_resource.to, @link_resource.name)
        link.remove!
        assert link.updated?
      end
    end

    it 'should return the update status if a link was not removed' do
      FakeFS do
        link = Wright::Provider::Symlink.new(@link_resource)
        link.remove!
        assert !link.updated?

        FileUtils.touch(@link_resource.name)
        proc { link.remove! }.must_raise RuntimeError
        assert !link.updated?
      end
    end
  end
end
