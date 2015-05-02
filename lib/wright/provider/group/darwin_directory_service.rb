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
          group = @resource.name
          gid = @resource.gid
          gid ||= next_system_gid if @resource.system
          options = gid.nil? ? [] : ['-i', gid.to_s]
          cmd = 'dseditgroup'
          args = ['-o', 'create', *options, group]
          exec_or_fail(cmd, args, "cannot create group '#{group}'")
        end

        def remove_group
          group = @resource.name
          cmd = 'dseditgroup'
          args = ['-o', 'delete', group]
          exec_or_fail(cmd, args, "cannot remove group '#{group}'")
        end

        def set_members
          group = @resource.name
          options = ['GroupMembership', *@resource.members]
          cmd = 'dscl'
          args = ['.', 'create', "/Groups/#{group}", *options]
          exec_or_fail(cmd, args, "cannot create group '#{group}'")
        end

        def set_gid
          group = @resource.name
          cmd = 'dseditgroup'
          args = ['-o', 'edit',
                  '-i', @resource.gid.to_s,
                  group]
          exec_or_fail(cmd, args, "cannot create group '#{group}'")
        end

        # Overrides Provider::Group#group_data to work around caching
        # issues with getgrnam(3) on OS X.
        def group_data
          Etc.group { |g| break g if g.name == @resource.name }
        end

        def next_system_gid
          system_gid_range = (1...500)
          Wright::Util::User.next_free_gid(system_gid_range)
        end
      end
    end
  end
end
