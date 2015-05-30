require 'open3'
require 'json'

require 'wright/provider'
require 'wright/provider/package'

module Wright
  class Provider
    class Package
      # Homebrew package provider. Used as a provider for
      # {Resource::Package} on OS X systems.
      class Homebrew < Wright::Provider::Package
        # @return [Array<String>] the installed package versions
        def installed_versions
          cmd = 'brew'
          args = ['info', '--json=v1', package_name]
          cmd_stdout, _, cmd_status = Wright::Util.bundler_clean_env do
            Open3.capture3(env, cmd, *args)
          end

          if cmd_status.success?
            JSON[cmd_stdout].first['installed'].map { |v| v['version'] }
          else
            []
          end
        end

        private

        def install_package
          brew(:install, package_name, package_version)
        end

        def remove_package
          brew(:uninstall, package_name)
        end

        def brew(action, package, version = nil)
          ignore_version(version)

          Wright::Util.bundler_clean_env do
            error_message = "cannot #{action} package '#{package}'"
            args = [action.to_s, *package_options, package]
            exec_or_fail('brew', args, error_message)
          end
        end

        def ignore_version(version)
          return unless version
          package_info = "#{package_name} (#{version})"
          Wright.log.warn "ignoring package version: '#{package_info}'"
        end
      end
    end
  end
end
