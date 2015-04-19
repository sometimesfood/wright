require 'wright/provider'
require 'wright/provider/package'

module Wright
  class Provider
    class Package
      # Apt package provider. Used as a provider for
      # {Resource::Package} on Debian-based systems.
      class Apt < Wright::Provider::Package
        # @return [Array<String>] the installed package versions
        def installed_versions
          package = @resource.name
          err = "Cannot determine installed versions for package '#{package}'"
          apt_policy = exec_or_fail('apt-cache', ['policy', package], err)

          version_re = /(?!\(none\)).*/
          installed_re = /^  Installed: (?<version>#{version_re})$/
          match = installed_re.match(apt_policy)
          match ? [match['version']] : []
        end

        private

        def install_package
          apt_get(:install, @resource.name, @resource.version)
        end

        def remove_package
          apt_get(:remove, @resource.name)
        end

        def apt_get(action, package, version = nil)
          package_version = version.nil? ? '' : "=#{version}"
          cmd = 'apt-get'
          args = [action.to_s, '-qy', package + package_version]
          exec_or_fail(cmd, args, "cannot #{action} package '#{package}'")
        end

        def env
          { 'DEBIAN_FRONTEND' => 'noninteractive' }
        end
      end
    end
  end
end
