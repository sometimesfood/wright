require 'wright/provider'
require 'wright/provider/user'
require 'wright/provider/user/useradd'

module Wright
  class Provider
    class User
      # GNU passwd user provider. Used as a provider for
      # {Resource::User} on GNU systems.
      class GnuPasswd < Wright::Provider::User::Useradd
        private

        def system_user_option
          '-r'
        end
      end
    end
  end
end
