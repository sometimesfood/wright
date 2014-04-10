require 'fileutils'
require 'wright/provider'
require 'wright/util/file'
require 'wright/util/user'

# Public: Directory provider. Used as a Provider for Resource::Directory.
class Wright::Provider::Directory < Wright::Provider

  # Public: Create or update the directory.
  #
  # Returns nothing.
  def create!
    if ::File.directory?(@resource.name) &&
        Util::File.mode_uptodate?(@resource.name, @resource.mode) &&
        Util::File.owner_uptodate?(@resource.name, @resource.owner) &&
        Util::File.group_uptodate?(@resource.name, @resource.group)
      Wright.log.debug "directory already created: '#{@resource.name}'"
      return
    end

    if ::File.exist?(@resource.name) && !::File.directory?(@resource.name)
      raise Errno::EEXIST, @resource.name
    end
    create_directory
    @updated = true
  end

  # Public: Remove the directory.
  #
  # Returns nothing.
  def remove!
    if ::File.exist?(@resource.name) && !::File.directory?(@resource.name)
      raise RuntimeError, "'#{@resource.name}' exists but is not a directory"
    end

    if ::File.directory?(@resource.name)
      if Wright.dry_run?
        Wright.log.info "(would) remove directory: '#{@resource.name}'"
      else
        Wright.log.info "remove directory: '#{@resource.name}'"
        FileUtils.rmdir(@resource.name)
      end
      @updated = true
    else
      Wright.log.debug "directory already removed: '#{@resource.name}'"
    end
  end

  private

  def create_directory
    dirname = @resource.name
    mode = Util::File.file_mode_to_i(@resource.mode, dirname)
    owner = @resource.owner
    group = @resource.group

    if Wright.dry_run?
      Wright.log.info "(would) create directory: '#{dirname}'"
    else
      Wright.log.info "create directory: '#{dirname}'"
      FileUtils.mkdir_p(dirname)
      FileUtils.chmod(mode, dirname) if @resource.mode
      FileUtils.chown(Util::User.user_to_uid(owner),
                      Util::User.group_to_gid(group),
                      dirname)
    end
  end
end
