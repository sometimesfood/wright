require 'wright/provider'
require 'wright/provider/user'

module Wright
  class Provider
    class User
      # GNU passwd user provider. Used as a provider for
      # {Resource::User} on GNU systems.
      class GnuPasswd < Wright::Provider::User
        private

        def add_user
          user = @resource.name
          exec_or_fail('useradd',
                       [*user_options, user],
                       "cannot create user '#{user}'")
        end

        def update_user
          user = @resource.name
          exec_or_fail('usermod',
                       [*user_options, user],
                       "cannot create user '#{user}'")
        end

        def user_options
          options = {
            '-u' => @resource.uid,
            '-g' => @resource.primary_group,
            '-c' => comment,
            '-G' => groups,
            '-s' => @resource.shell,
            '-d' => @resource.home
          }.reject { |_k, v| v.nil? }.flatten
          options << '-r' if @resource.system
          options.map(&:to_s)
        end

        def comment
          @resource.full_name.nil? ? nil : "#{@resource.full_name},,,"
        end

        def groups
          @resource.groups.nil? ? nil : @resource.groups.join(',')
        end

        def delete_user
          user = @resource.name
          exec_or_fail('userdel', [user], "cannot remove user '#{user}'")
        end
      end
    end
  end
end
