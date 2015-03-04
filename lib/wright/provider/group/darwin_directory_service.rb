require 'open3'

require 'wright/dry_run'
require 'wright/provider/group'

module Wright
  class Provider
    class Group
      # Darwin DirectoryService group provider. Used as a provider for
      # {Resource::Group} on OS X systems.
      class DarwinDirectoryService < Wright::Provider::Group
        private

        def add_group(group_name, gid)
          options = ''
          options += "-i #{gid}" if gid
          cmd = "dseditgroup -o create #{options} #{group_name}"
          _, cmd_stderr, cmd_status = Open3.capture3(env, cmd)
          return if cmd_status.success?

          error = cmd_stderr.chomp
          fail %(cannot create group '#{group_name}': "#{error}")
        end

        def delete_group(group_name)
          cmd = "dseditgroup -o delete #{group_name}"
          _, cmd_stderr, cmd_status = Open3.capture3(env, cmd)
          return if cmd_status.success?

          error = cmd_stderr.chomp
          fail %(cannot remove group '#{group_name}': "#{error}")
        end

        def set_members(group_name, members)
          return if members.nil?
          options = "GroupMembership '#{members.join(' ')}'"
          cmd = "dscl . create /Groups/#{group_name} #{options}"
          _, cmd_stderr, cmd_status = Open3.capture3(env, cmd)
          return if cmd_status.success?

          error = cmd_stderr.chomp
          fail %(cannot create group '#{group_name}': "#{error}")
        end

        def set_gid(group_name, gid)
          return if gid.nil?

          cmd = "dseditgroup -o edit -i #{gid} #{group_name}"
          _, cmd_stderr, cmd_status = Open3.capture3(env, cmd)
          return if cmd_status.success?

          error = cmd_stderr.chomp
          fail %(cannot create group '#{group_name}': "#{error}")
        end

        # Overrides Provider::Group#group_data to work around caching
        # issues with getgrnam(3) on OS X
        def group_data
          Etc.group { |g| break g if g.name == @resource.name }
        end
      end
    end
  end
end
