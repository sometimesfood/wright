require 'wright/provider'
require 'wright/provider/package'

module Wright
  class Provider
    class Package
      # OpenBSD package provider. Used as a provider for
      # {Resource::Package} on OpenBSD systems.
      class Openbsd < Wright::Provider::Package
        # @return [Array<String>] the installed package versions
        def installed_versions
          # see packages-specs(7) and OpenBSD::PackageName(3p) for details
          version_re = /^inst:(?<stem>.*?)\-(?<version>\d.*)$/
          match = version_re.match(pkg_info)
          match ? [match['version']] : []
        end

        private

        def install_package
          pkg_add(package_options, package_name, package_version)
        end

        def remove_package
          pkg_delete(package_options, package_name)
        end

        def pkg_info
          pkg_info_cmd = %W[pkg_info -e #{package_name}->0]
          stdout = Open3.capture3(env, *pkg_info_cmd).first
          stdout
        end

        def pkg_add(options, package, version = nil)
          package_version = version.nil? ? '' : "-#{version}"
          cmd = 'pkg_add'
          args = [*options, package + package_version]
          error_message = "cannot install package '#{package}'"
          exec_or_fail(cmd, args, error_message, ignore_stderr: false)
        end

        def pkg_delete(options, package)
          cmd = 'pkg_delete'
          args = [*options, package]
          error_message = "cannot remove package '#{package}'"
          exec_or_fail(cmd, args, error_message, ignore_stderr: false)
        end
      end
    end
  end
end
