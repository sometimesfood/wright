require 'wright/provider'
require 'wright/util/file'
require 'wright/util/user'
require 'fileutils'
require 'digest'
require 'tempfile'
require 'tmpdir'

# Public: File provider. Used as a Provider for Resource::File.
class Wright::Provider::File < Wright::Provider

  # Public: Create or update the File.
  #
  # Returns nothing.
  def create!
    if ::File.directory?(@resource.name)
      raise Errno::EISDIR, @resource.name
    end

    if uptodate?
      Wright.log.debug "file already created: #{@resource.name}"
      return
    end

    create_file
    @updated = true
  end

  # Public: Remove the File.
  #
  # Returns nothing.
  def remove!
    if ::File.directory?(@resource.name)
      raise Errno::EISDIR, @resource.name
    end

    file = @resource.name
    if ::File.exist?(file) || ::File.symlink?(file)
      if Wright.dry_run?
        Wright.log.info "(would) remove file: '#{file}'"
      else
        Wright.log.info "remove file: '#{file}'"
        FileUtils.rm(file)
      end
      @updated = true
    else
      Wright.log.debug "file already removed: '#{file}'"
    end
  end

  private

  def create_file
    if Wright.dry_run?
      Wright.log.info "(would) create file: '#{@resource.name}'"
    else
      Wright.log.info "create file: '#{@resource.name}'"
      file = Tempfile.new(::File.basename(@resource.name))
      file.write(@resource.content) if @resource.content
      file.close
      if @resource.content || !::File.exist?(@resource.name)
        FileUtils.mv(file.path, @resource.name)
      else
        file.unlink
      end
      mode = Wright::Util::File.file_mode_to_i(@resource.mode, @resource.name)
      FileUtils.chmod(mode, @resource.name) if @resource.mode
      FileUtils.chown(Wright::Util::User.user_to_uid(@resource.owner),
                      Wright::Util::User.group_to_gid(@resource.group),
                      @resource.name)
    end
  end

  # oh noes, copy and paste!
  def mode_uptodate?
    return true unless @resource.mode
    target_mode = Wright::Util::File.file_mode_to_i(@resource.mode, @resource.name)
    current_mode = Wright::Util::File.file_mode(@resource.name)
    current_mode == target_mode
  end

  def owner_uptodate?
    return true unless @resource.owner
    target_owner = Wright::Util::User.user_to_uid(@resource.owner)
    current_owner = Wright::Util::File.file_owner(@resource.name)
    current_owner == target_owner
  end

  def group_uptodate?
    return true unless @resource.group
    target_group = Wright::Util::User.group_to_gid(@resource.group)
    current_group = Wright::Util::File.file_group(@resource.name)
    current_group == target_group
  end
  ###################

  def checksum(content)
    Digest::SHA256.hexdigest(content)
  end

  def content_uptodate?
    return false unless ::File.exist?(@resource.name)
    content = @resource.content || ''
    target_checksum = checksum(content)
    current_checksum = checksum(::File.read(@resource.name))
    return current_checksum == target_checksum
  end

  def uptodate?
    content_uptodate? &&
      mode_uptodate? &&
      owner_uptodate? &&
      group_uptodate?
  end
end
