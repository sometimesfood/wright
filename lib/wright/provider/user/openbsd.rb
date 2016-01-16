require 'wright/provider'
require 'wright/provider/user/useradd'

module Wright
  class Provider
    class User
      # OpenBSD user provider. Used as a provider for {Resource::User}
      # on OpenBSD systems.
      class Openbsd < Wright::Provider::User::Useradd
        private

        def system_user_option
          min_uid = 100
          max_uid = 999
          "-r #{min_uid}..#{max_uid}"
        end
      end
    end
  end
end
