require 'wright/provider'
require 'wright/provider/user'

module Wright
  class Provider
    class User
      # Darwin DirectoryService user provider. Used as a provider for
      # {Resource::User} on OS X systems.
      class DarwinDirectoryService < User
        private

        def add_user
          user = @resource.name
          attributes = default_attributes.merge(resource_attributes)
          attributes.each do |k, v|
            args = dscl_args(:create, k, v)
            exec_or_fail('dscl', args, "cannot create user '#{user}'")
          end
        end

        def update_user
          user = @resource.name
          resource_attributes.each do |k, v|
            args = dscl_args(:create, k, v)
            exec_or_fail('dscl', args, "cannot create user '#{user}'")
          end
        end

        def delete_user
          user = @resource.name
          exec_or_fail('dscl',
                       %W(. -delete /Users/#{user}),
                       "cannot remove user '#{user}'")
        end

        def dscl_args(cmd, key, value)
          %W(. -#{cmd} /Users/#{@resource.name} #{key} #{value})
        end

        def default_attributes
          uid_range = @resource.system ? 1...500 : 500...1000
          {
            'UniqueID' => Wright::Util::User.next_free_uid(uid_range),
            'UserShell' => '/bin/bash',
            'RealName' => '',
            'NFSHomeDirectory' => "/Users/#{@resource.name}",
            'PrimaryGroupID' => Wright::Util::User.group_to_gid('staff'),
            'Password' => '*'
          }
        end

        def resource_attributes
          gid = Wright::Util::User.group_to_gid(@resource.primary_group)
          {
            'UniqueID' => @resource.uid,
            'UserShell' => @resource.shell,
            'RealName' => @resource.full_name,
            'NFSHomeDirectory' => @resource.home,
            'PrimaryGroupID' => gid
          }.reject { |_k, v| v.nil? }
        end
      end
    end
  end
end
