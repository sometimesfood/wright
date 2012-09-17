require 'wright/provider'
require 'fileutils'

# Public: Symlink provider. Used as a Provider for Resource::Symlink.
class Wright::Provider::Symlink < Wright::Provider

  # Public: Create or update the Symlink.
  #
  # Returns nothing.
  def create!
    unless exist?
      if File.exist?(@resource.target) && !File.symlink?(@resource.target)
        raise Errno::EEXIST, @resource.target
      end
      ln_sfn(@resource.source, @resource.target)
      @updated = true
    end
  end

  # Public: Remove the Symlink.
  #
  # Returns nothing.
  def remove!
    if File.exist?(@resource.target) && !File.symlink?(@resource.target)
      raise RuntimeError, "#{@resource.target} is not a symlink"
    end

    if File.symlink?(@resource.target)
      FileUtils.rm(@resource.target)
      @updated = true
    end
  end

  private
  # Internal: Checks if the specified link exists.
  #
  # Returns true if the link exists and has the specified source and
  # false otherwise.
  def exist? #:doc:
    File.symlink?(@resource.target) &&
      File.readlink(@resource.target) == @resource.source
  end

  # Internal: Creates a link to a source file named target.
  #
  # If the target is a symlink to a directory, ln_sfn does not descend
  # into it, similar to "ln -sfn source target".
  #
  # Returns nothing.
  def ln_sfn(source, target)
    if File.symlink?(target) && File.directory?(target)
      FileUtils.rm(target)
    end
    FileUtils.ln_sf(source, target)
  end
end
