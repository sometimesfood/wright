require 'wright/provider'
require 'fileutils'

class Wright::Provider::Link < Wright::Provider
  def create!
    unless exist?
      if File.exist?(@resource.target) && !File.symlink?(@resource.target)
        raise Errno::EEXIST, @resource.target
      end
      ln_sfn(@resource.source, @resource.target)
      @updated = true
    end
  end

  def remove!
    if File.exist?(@resource.target) && !File.symlink?(@resource.target)
      raise RuntimeError, "#{@resource.target} is not a symlink"
    end

    if File.symlink?(@resource.target)
      FileUtils.rm(@resource.target)
      @updated = true
    end
  end

  def exist?
    File.symlink?(@resource.target) &&
      File.readlink(@resource.target) == @resource.source
  end

  def ln_sfn(source, target)
    # if target is a symlink to a directory, don't descend (similar to
    # GNU ln's -n option and OpenBSD ln's -h option)
    if File.symlink?(target) && File.directory?(target)
      FileUtils.rm(target)
    end
    FileUtils.ln_sf(source, target)
  end
end
