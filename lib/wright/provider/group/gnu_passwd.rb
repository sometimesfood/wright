require 'wright/provider'
require 'wright/provider/group'

module Wright
  class Provider
    class Group
      # GNU passwd group provider. Used as a provider for
      # {Resource::Group} on GNU systems.
      class GnuPasswd < Wright::Provider::Group
        private

        def add_group(group_name, gid, system)
          options = []
          options << '--system' if system
          options += ['-g', gid.to_s] if gid
          cmd = 'groupadd'
          args = [*options, group_name]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end

        def delete_group(group_name)
          cmd = 'groupdel'
          args = [group_name]
          exec_or_fail(cmd, args, "cannot remove group '#{group_name}'")
        end

        def set_members(group_name, members)
          cmd = 'gpasswd'
          args = ['-M', "'#{members.join(',')}'", group_name]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end

        def set_gid(group_name, gid)
          cmd = 'groupmod'
          args = ['-g', gid.to_s, group_name]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end
      end
    end
  end
end
