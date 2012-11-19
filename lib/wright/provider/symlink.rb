require 'wright/provider'
require 'fileutils'

# Public: Symlink provider. Used as a Provider for Resource::Symlink.
class Wright::Provider::Symlink < Wright::Provider

  # Public: Create or update the Symlink.
  #
  # Returns nothing.
  def create!
    if exist?
      symlink = symlink_to_s(@resource.name, @resource.to)
      Wright.log.debug "symlink already created: #{symlink}"
      return
    end

    if File.exist?(@resource.name) && !File.symlink?(@resource.name)
      raise Errno::EEXIST, @resource.name
    end
    ln_sfn(@resource.to, @resource.name)
    @updated = true
  end

  # Public: Remove the Symlink.
  #
  # Returns nothing.
  def remove!
    if File.exist?(@resource.name) && !File.symlink?(@resource.name)
      raise RuntimeError, "'#{@resource.name}' is not a symlink"
    end

    if File.symlink?(@resource.name)
      if Wright.dry_run?
        Wright.log.info "(would) remove symlink: '#{@resource.name}'"
      else
        Wright.log.info "remove symlink: '#{@resource.name}'"
        FileUtils.rm(@resource.name)
      end
      @updated = true
    else
      Wright.log.debug "symlink already removed: '#{@resource.name}'"
    end
  end

  private
  # Internal: Checks if the specified link exists.
  #
  # Returns true if the link exists and points to the specified target
  # and false otherwise.
  def exist? #:doc:
    File.symlink?(@resource.name) &&
      File.readlink(@resource.name) == @resource.to
  end

  # Internal: Creates a link named link_name to target.
  #
  # If the file denoted by link_name is a symlink to a directory,
  # ln_sfn does not descend into it. Behaves similar to GNU ln(1) or
  # OpenBSD ln(1) when using "ln -sfn to link_name".
  #
  # Returns nothing.
  def ln_sfn(target, link_name)
    symlink = symlink_to_s(link_name, target)
    if Wright.dry_run?
      Wright.log.info "(would) create symlink: #{symlink}"
    else
      Wright.log.info "create symlink: #{symlink}"
      if File.symlink?(link_name) && File.directory?(link_name)
        FileUtils.rm(link_name)
      end
      FileUtils.ln_sf(target, link_name)
    end
  end

  def symlink_to_s(link_name, target)
    "'#{link_name}' -> '#{target}'"
  end
end
