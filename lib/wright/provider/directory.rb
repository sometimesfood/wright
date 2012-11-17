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
    if File.directory?(@resource.name) &&
        mode_uptodate? &&
        owner_uptodate? &&
        group_uptodate?
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

  def owner_uptodate?
    return true unless @resource.owner
    target_owner = Util::User.user_to_uid(@resource.owner)
    current_owner = Util::File.file_owner(@resource.name)
    current_owner == target_owner
  end

  def group_uptodate?
    return true unless @resource.group
    target_group = Util::User.group_to_gid(@resource.group)
    current_group = Util::File.file_group(@resource.group)
    current_group == target_group
  end

  def create_directory
    dirname = @resource.name
    mode = Wright::Util::File.file_mode_to_i(@resource.mode, dirname)
    owner = @resource.owner
    group = @resource.group
    directory = "#{dirname} (#{mode.to_s(8)}, #{owner}:#{group})"
    if Wright.dry_run?
      Wright.log.info "(would) create directory: #{directory}"
    else
      Wright.log.info "create directory: #{directory}"
      FileUtils.mkdir_p(dirname)
      FileUtils.chmod(mode, dirname) if @resource.mode
      FileUtils.chown(Wright::Util::User.user_to_uid(owner),
                      Wright::Util::User.group_to_gid(group),
                      dirname)
    end
  end
end