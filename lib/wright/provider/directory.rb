require 'wright/provider'
require 'fileutils'

# Public: Directory provider. Used as a Provider for Resource::Directory.
class Wright::Provider::Directory < Wright::Provider

  # Public: Create or update the directory.
  #
  # Returns nothing.
  def create!
    if exist?
      Wright.log.debug "directory already created: #{@resource.name}"
      return
    end

    if File.exist?(@resource.name) && !File.directory?(@resource.name)
      raise Errno::EEXIST, @resource.name
    end
    mkdir_p(@resource.name)
    @updated = true
  end

  # Public: Remove the directory.
  #
  # Returns nothing.
  def remove!
    if File.exist?(@resource.name) && !File.directory?(@resource.name)
      raise RuntimeError, "#{@resource.name} is not a directory"
    end

    if File.directory?(@resource.name)
      if Wright.dry_run?
        Wright.log.info "(would) remove directory: #{@resource.name}"
      else
        Wright.log.info "remove directory: #{@resource.name}"
        FileUtils.rmdir(@resource.name)
      end
      @updated = true
    else
      Wright.log.debug "directory already removed: #{@resource.name}"
    end
  end

  private

  # Internal: Checks if the specified directory exists.
  #
  # Returns true if the directory exists and false otherwise.
  def exist? #:doc:
    File.directory?(@resource.name)
  end

  def mkdir_p(dirname)
    if Wright.dry_run?
      Wright.log.info "(would) create directory: #{dirname}"
    else
      Wright.log.info "create directory: #{dirname}"
      FileUtils.mkdir_p(dirname)
    end
  end
end
