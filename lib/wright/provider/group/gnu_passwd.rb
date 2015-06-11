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
          options = []
          options << '--system' if system_group?
          options += ['-g', gid.to_s] if gid
          cmd = 'groupadd'
          args = [*options, group_name]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end

        def remove_group
          cmd = 'groupdel'
          args = [group_name]
          exec_or_fail(cmd, args, "cannot remove group '#{group_name}'")
        end

        def set_members
          cmd = 'gpasswd'
          args = ['-M', members.join(','), group_name]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end

        def set_gid
          cmd = 'groupmod'
          args = ['-g', gid.to_s, group_name]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end
      end
    end
  end
end
