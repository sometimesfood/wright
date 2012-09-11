require_relative '../spec_helper'

require 'wright/provider/link'
require 'fileutils'

describe Wright::Provider::Link do
  before(:each) do
    @link_resource = MiniTest::Mock.new
    @link_resource.expect(:source, 'foo')
    @link_resource.expect(:target, 'bar')
  end

  after(:each) do
    FakeFS::FileSystem.clear
  end

  it 'should set its update status if a link was created' do
    FakeFS do
      link = Wright::Provider::Link.new(@link_resource)
      link.create!
      assert link.updated?
    end
  end

  it 'should not change its update status if no link was created' do
    FakeFS do
      link = Wright::Provider::Link.new(@link_resource)
      assert !link.updated?
      FileUtils.ln_sf(@link_resource.source, @link_resource.target)
      link.create!
      assert !link.updated?

      FileUtils.rm(@link_resource.target)
      FileUtils.touch(@link_resource.target)
      proc { link.create! }.must_raise Errno::EEXIST
      assert !link.updated?
    end
  end

  it 'should set its update status if a link was changed' do
    FakeFS do
      FileUtils.ln_sf('old-source', @link_resource.target)
      link = Wright::Provider::Link.new(@link_resource)
      link.create!
      assert link.updated?
    end
  end

  it 'should not change its update status if a link was not changed' do
    FakeFS do
      link = Wright::Provider::Link.new(@link_resource)
      assert !link.updated?
      FileUtils.ln_sf(@link_resource.source, @link_resource.target)
      link.create!
      assert !link.updated?
    end
  end

  it 'should set its update status if a link was removed' do
    FakeFS do
      link = Wright::Provider::Link.new(@link_resource)
      FileUtils.ln_sf(@link_resource.source, @link_resource.target)
      link.remove!
      assert link.updated?
    end
  end

  it 'should not change its update status if a link was not removed' do
    FakeFS do
      link = Wright::Provider::Link.new(@link_resource)
      assert !link.updated?
      link.remove!
      assert !link.updated?

      FileUtils.touch(@link_resource.target)
      proc { link.remove! }.must_raise RuntimeError
      assert !link.updated?
    end
  end
end
