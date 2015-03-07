require 'wright/dry_run'
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
          options << "-g #{gid}" if gid
          cmd = "groupadd #{options.join(' ')} #{group_name}"
          exec_or_fail(cmd, "cannot create group '#{group_name}'")
        end

        def delete_group(group_name)
          cmd = "groupdel #{group_name}"
          exec_or_fail(cmd, "cannot remove group '#{group_name}'")
        end

        def set_members(group_name, members)
          cmd = "gpasswd -M '#{members.join(',')}' #{group_name}"
          exec_or_fail(cmd, "cannot create group '#{group_name}'")
        end

        def set_gid(group_name, gid)
          cmd = "groupmod -g #{gid} #{group_name}"
          exec_or_fail(cmd, "cannot create group '#{group_name}'")
        end
      end
    end
  end
end
