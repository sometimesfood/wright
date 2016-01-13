require 'wright/provider'
require 'wright/provider/group/groupadd'

module Wright
  class Provider
    class Group
      # GNU group provider. Used as a provider for {Resource::Group}
      # on GNU systems.
      class Gnu < Wright::Provider::Group::Groupadd
        private

        def system_group_option
          '-r'
        end

        def set_members
          cmd = 'gpasswd'
          args = ['-M', members.join(','), group_name]
          exec_or_fail(cmd, args, "cannot create group '#{group_name}'")
        end
      end
    end
  end
end
