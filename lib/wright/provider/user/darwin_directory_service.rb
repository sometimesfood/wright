require 'wright/provider'
require 'wright/provider/user'

module Wright
  class Provider
    class User
      # Darwin DirectoryService user provider. Used as a provider for
      # {Resource::User} on OS X systems.
      class DarwinDirectoryService < User
        private

        def create_user
          attributes = default_attributes.merge(resource_attributes)
          attributes.each do |k, v|
            args = dscl_args(:create, k, v)
            exec_or_fail('dscl', args, "cannot create user '#{user_name}'")
          end
        end

        def update_user
          resource_attributes.each do |k, v|
            args = dscl_args(:create, k, v)
            exec_or_fail('dscl', args, "cannot create user '#{user_name}'")
          end
        end

        def remove_user
          exec_or_fail('dscl',
                       %W(. -delete /Users/#{user_name}),
                       "cannot remove user '#{user_name}'")
        end

        def dscl_args(cmd, key, value)
          %W(. -#{cmd} /Users/#{user_name} #{key} #{value})
        end

        def default_attributes
          uid_range = system_user? ? 1...500 : 500...1000
          {
            'UniqueID' => Wright::Util::User.next_free_uid(uid_range),
            'UserShell' => '/bin/bash',
            'RealName' => '',
            'NFSHomeDirectory' => "/Users/#{user_name}",
            'PrimaryGroupID' => Wright::Util::User.group_to_gid('staff'),
            'Password' => '*'
          }
        end

        def resource_attributes
          gid = Wright::Util::User.group_to_gid(primary_group)
          {
            'UniqueID' => uid,
            'UserShell' => shell,
            'RealName' => full_name,
            'NFSHomeDirectory' => home,
            'PrimaryGroupID' => gid
          }.reject { |_k, v| v.nil? }
        end
      end
    end
  end
end
