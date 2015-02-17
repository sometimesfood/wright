require 'open3'

require 'wright/dry_run'
require 'wright/provider'
require 'wright/provider/group'

module Wright
  class Provider
    class Group
      # GNU passwd group provider. Used as a provider for
      # {Resource::Group} on GNU systems.
      class GnuPasswd < Wright::Provider::Group
        private

        def add_group(group_name, gid)
          options = ''
          options += "-g #{gid}" if gid
          groupadd_cmd = "groupadd #{options} #{group_name}"
          _, cmd_stderr, cmd_status = Open3.capture3(env, groupadd_cmd)
          return if cmd_status.success?

          groupadd_error = cmd_stderr.chomp
          fail %(cannot create group '#{group_name}': "#{groupadd_error}")
        end

        def delete_group(group_name)
          groupdel_cmd = "groupdel #{group_name}"
          _, cmd_stderr, cmd_status = Open3.capture3(env, groupdel_cmd)
          return if cmd_status.success?

          groupdel_error = cmd_stderr.chomp
          fail %(cannot remove group '#{group_name}': "#{groupdel_error}")
        end

        def set_members(group_name, members)
          return if members.nil?
          options = "-M '#{members.join(',')}'"
          gpasswd_cmd = "gpasswd #{options} #{group_name}"
          _, cmd_stderr, cmd_status = Open3.capture3(env, gpasswd_cmd)
          return if cmd_status.success?

          gpasswd_error = cmd_stderr.chomp
          fail %(cannot create group '#{group_name}': "#{gpasswd_error}")
        end

        def set_gid(group_name, gid)
          return if gid.nil?
          groupmod_cmd = "groupmod -g #{gid} #{group_name}"
          _, cmd_stderr, cmd_status = Open3.capture3(env, groupmod_cmd)
          return if cmd_status.success?

          groupmod_error = cmd_stderr.chomp
          fail %(cannot create group '#{group_name}': "#{groupmod_error}")
        end

        def env
          {}
        end
      end
    end
  end
end
