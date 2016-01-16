require 'wright/provider'
require 'wright/provider/group'

module Wright
  class Provider
    class Group
      # Darwin DirectoryService group provider. Used as a provider for
      # {Resource::Group} on OS X systems.
      class DarwinDirectoryService < Wright::Provider::Group
        private

        def create_group
          target_gid = gid
          target_gid ||= next_system_gid if system_group?
          options = target_gid.nil? ? [] : ['-i', target_gid.to_s]
          cmd = 'dseditgroup'
          args = ['-o', 'create', *options, group_name]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end

        def remove_group
          cmd = 'dseditgroup'
          args = ['-o', 'delete', group_name]
          exec_or_fail(cmd, args, "cannot remove group '#{group_name}'")
        end

        def set_members
          options = ['GroupMembership', *members]
          cmd = 'dscl'
          args = ['.', 'create', "/Groups/#{group_name}", *options]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end

        def set_gid
          cmd = 'dseditgroup'
          args = ['-o', 'edit',
                  '-i', gid.to_s,
                  group_name]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end

        # Overrides Provider::Group#group_data to work around caching
        # issues with getgrnam(3) on OS X.
        def group_data
          Etc.group { |g| break g if g.name == group_name }
        end

        def system_gid_range
          (1..499)
        end
      end
    end
  end
end
