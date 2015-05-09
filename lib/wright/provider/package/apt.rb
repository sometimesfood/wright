require 'ostruct'

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
          package = "package '#{package_name}'"
          err = "Cannot determine installed versions for #{package}"
          apt_policy = exec_or_fail('apt-cache', ['policy', package_name], err)

          version_re = /(?!\(none\)).*/
          installed_re = /^  Installed: (?<version>#{version_re})$/
          match = installed_re.match(apt_policy)
          match ? [match['version']] : virtual_package_versions
        end

        private

        def install_package
          apt_get(:install, package_name, package_version)
        end

        def remove_package
          apt_get(:remove, package_name)
        end

        def apt_get(action, package, version = nil)
          package_version = version.nil? ? '' : "=#{version}"
          cmd = 'apt-get'
          args = [action.to_s, '-qy', package + package_version]
          exec_or_fail(cmd, args, "cannot #{action} package '#{package}'")
        end

        def virtual_package_versions
          virtual_package_installed? ? ['virtual'] : []
        end

        # @todo replace the OpenStruct hack below by a direct
        #   instantiation of {Wright::Resource::Package} as soon as
        #   the resource-provider mapping can be changed more easily
        def virtual_package_installed?
          err = 'Error executing apt-cache'
          showpkg = exec_or_fail('apt-cache', ['showpkg', package_name], err)
          reverse_provides = showpkg.partition("Reverse Provides: \n").last
          provided_by = reverse_provides.split("\n")
          provided_by.any? do |package_line|
            name, version = package_line.split(' ')
            resource = OpenStruct.new(name: name, version: version)
            package = Wright::Provider::Package::Apt.new(resource)
            package.installed?
          end
        end

        def env
          { 'DEBIAN_FRONTEND' => 'noninteractive' }
        end
      end
    end
  end
end
