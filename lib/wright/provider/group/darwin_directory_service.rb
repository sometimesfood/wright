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

        def add_group(group_name, gid, system)
          gid ||= next_system_gid if system
          options = gid.nil? ? '' : "-i #{gid}"
          cmd = "dseditgroup -o create #{options} #{group_name}"
          exec_or_fail(cmd, "cannot create group '#{group_name}'")
        end

        def delete_group(group_name)
          cmd = "dseditgroup -o delete #{group_name}"
          exec_or_fail(cmd, "cannot remove group '#{group_name}'")
        end

        def set_members(group_name, members)
          options = "GroupMembership '#{members.join(' ')}'"
          cmd = "dscl . create /Groups/#{group_name} #{options}"
          exec_or_fail(cmd, "cannot create group '#{group_name}'")
        end

        def set_gid(group_name, gid)
          cmd = "dseditgroup -o edit -i #{gid} #{group_name}"
          exec_or_fail(cmd, "cannot create group '#{group_name}'")
        end

        # Overrides Provider::Group#group_data to work around caching
        # issues with getgrnam(3) on OS X.
        def group_data
          Etc.group { |g| break g if g.name == @resource.name }
        end

        def next_system_gid
          system_gid_range = (1...500)
          used_system_gids = []
          Etc.group do |g|
            used_system_gids << g.gid if system_gid_range.include?(g.gid)
          end
          free_system_gids = system_gid_range.to_a - used_system_gids
          fail 'No free gids in system gid range' if free_system_gids.empty?
          free_system_gids.max
        end
      end
    end
  end
end
