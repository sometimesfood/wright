require 'wright/provider'
require 'wright/provider/user'

module Wright
  class Provider
    class User
      # useradd user provider. Used as a baseclass for user providers
      # on systems with useradd(8), usermod(8) and userdel(8).
      class Useradd < Wright::Provider::User
        private

        def create_user
          exec_or_fail('useradd',
                       [*user_options, user_name],
                       "cannot create user '#{user_name}'")
        end

        def update_user
          exec_or_fail('usermod',
                       [*user_options, user_name],
                       "cannot create user '#{user_name}'")
        end

        def remove_user
          exec_or_fail('userdel',
                       [user_name],
                       "cannot remove user '#{user_name}'")
        end

        def user_options
          options = {
            '-u' => uid,
            '-g' => primary_group,
            '-c' => comment,
            '-G' => group_list,
            '-s' => shell,
            '-d' => home
          }.reject { |_k, v| v.nil? }.flatten
          options << system_user_option if system_user?
          options.map(&:to_s)
        end

        def system_user_option
          raise NotImplementedError
        end

        def comment
          full_name.nil? ? nil : "#{full_name},,,"
        end

        def group_list
          groups.nil? ? nil : groups.join(',')
        end
      end
    end
  end
end
