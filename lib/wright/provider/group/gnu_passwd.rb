require 'wright/provider'
require 'wright/provider/group'

module Wright
  class Provider
    class Group
      # GNU passwd group provider. Used as a provider for
      # {Resource::Group} on GNU systems.
      class GnuPasswd < Wright::Provider::Group
        private

        def create_group
          group = @resource.name
          gid = @resource.gid
          options = []
          options << '--system' if @resource.system
          options += ['-g', gid.to_s] if gid
          cmd = 'groupadd'
          args = [*options, group]
          exec_or_fail(cmd, args, "cannot create group '#{group}'")
        end

        def remove_group
          group = @resource.name
          cmd = 'groupdel'
          args = [group]
          exec_or_fail(cmd, args, "cannot remove group '#{group}'")
        end

        def set_members
          group = @resource.name
          cmd = 'gpasswd'
          args = ['-M', "'#{@resource.members.join(',')}'", group]
          exec_or_fail(cmd, args, "cannot create group '#{group}'")
        end

        def set_gid
          group = @resource.name
          cmd = 'groupmod'
          args = ['-g', @resource.gid.to_s, group]
          exec_or_fail(cmd, args, "cannot create group '#{group}'")
        end
      end
    end
  end
end
