require 'wright/provider'
require 'fileutils'

# Public: Directory provider. Used as a Provider for Resource::Directory.
class Wright::Provider::Directory < Wright::Provider

  # Public: Create or update the directory.
  #
  # Returns nothing.
  def create!
    if File.directory?(@resource.name) && mode_uptodate?
      Wright.log.debug "directory already created: #{@resource.name}"
      return
    end

    if File.exist?(@resource.name) && !File.directory?(@resource.name)
      raise Errno::EEXIST, @resource.name
    end
    create_directory
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

  def mode_uptodate?
    return true unless @resource.mode
    target_mode = Util::File.file_mode_to_i(@resource.mode, @resource.name)
    current_mode = Util::File.file_mode(@resource.name)
    current_mode == target_mode
  end

  def create_directory
    dirname = @resource.name
    mode = Wright::Util::File.file_mode_to_i(@resource.mode, dirname)
    directory = "#{dirname} (#{mode.to_s(8)})"
    if Wright.dry_run?
      Wright.log.info "(would) create directory: #{directory}"
    else
      Wright.log.info "create directory: #{directory}"
      FileUtils.mkdir_p(dirname)
      FileUtils.chmod(mode, dirname)
    end
  end
end
