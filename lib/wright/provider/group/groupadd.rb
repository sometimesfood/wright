require 'wright/provider'
require 'wright/provider/group'

module Wright
  class Provider
    class Group
      # groupadd group provider. Used as a baseclass for group
      # providers on systems with groupadd(8), groupmod(8) and
      # groupdel(8).
      class Groupadd < Wright::Provider::Group
        private

        def create_group
          options = []
          options << system_group_option if system_group?
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

        def set_gid
          cmd = 'groupmod'
          args = ['-g', gid.to_s, group_name]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end

        def system_group_option
          fail NotImplementedError
        end
      end
    end
  end
end
