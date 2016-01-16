require 'wright/provider'
require 'wright/provider/group/groupadd'

module Wright
  class Provider
    class Group
      # OpenBSD group provider. Used as a provider for
      # {Resource::Group} on OpenBSD systems.
      class Openbsd < Wright::Provider::Group::Groupadd
        private

        def system_group_option
          "-g #{next_system_gid}"
        end
      end
    end
  end
end
