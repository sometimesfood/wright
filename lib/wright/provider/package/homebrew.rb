require 'open3'
require 'json'

require 'wright/dry_run'
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
          cmd = "brew info --json=v1 #{@resource.name}"
          cmd_stdout, _, cmd_status = Wright::Util.bundler_clean_env do
            Open3.capture3(env, cmd.shellescape)
          end

          if cmd_status.success?
            JSON[cmd_stdout].first['installed'].map { |v| v['version'] }
          else
            []
          end
        end

        # Installs the package.
        #
        # @return [void]
        def install
          if uptodate?(:install)
            Wright.log.debug "package already installed: '#{@resource.name}'"
            return
          end

          install_package
          @updated = true
        end

        # Removes the package.
        #
        # @return [void]
        def remove
          if uptodate?(:remove)
            Wright.log.debug "package already removed: '#{@resource.name}'"
            return
          end

          remove_package
          @updated = true
        end

        private

        def install_package
          package = @resource.name
          unless_dry_run("install package: '#{package}'") do
            brew(:install, package, @resource.version)
          end
        end

        def remove_package
          package = @resource.name
          unless_dry_run("remove package: '#{package}'") do
            brew(:uninstall, package)
          end
        end

        def brew(action, package, version = nil)
          ignore_version(version)

          brew_cmd = "brew #{action} #{package}"

          _, cmd_stderr, cmd_status = Wright::Util.bundler_clean_env do
            Open3.capture3(env, brew_cmd.shellescape)
          end
          return if cmd_status.success?

          brew_error = cmd_stderr.chomp
          fail %(cannot #{action} package '#{package}': "#{brew_error}")
        end

        def ignore_version(version)
          return unless version
          package_info = "#{@resource.name} (#{version})"
          Wright.log.warn "ignoring package version: '#{package_info}'"
        end
      end
    end
  end
end
