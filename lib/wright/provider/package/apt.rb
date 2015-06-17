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
          apt_get(:install, package_options, package_name, package_version)
        end

        def remove_package
          apt_get(:remove, package_options, package_name)
        end

        def apt_get(action, options, package, version = nil)
          package_version = version.nil? ? '' : "=#{version}"
          cmd = 'apt-get'
          args = ['-qy', *options, action.to_s, package + package_version]
          exec_or_fail(cmd, args, "cannot #{action} package '#{package}'")
        end

        def virtual_package_versions
          virtual_package_installed? ? ['virtual'] : []
        end

        # @todo replace the OpenStruct hack below by a direct
        #   instantiation of {Wright::Resource::Package} as soon as
        #   the resource-provider mapping can be changed more easily
        def virtual_package_installed?
          reverse_provides.any? do |name, version|
            resource = OpenStruct.new(name: name, version: version)
            package = Wright::Provider::Package::Apt.new(resource)
            package.installed?
          end
        end

        def reverse_provides
          err = 'Error executing apt-cache'
          showpkg = exec_or_fail('apt-cache', ['showpkg', package_name], err)
          packages = showpkg.partition("Reverse Provides: \n").last.split("\n")
          Hash[packages.map { |p| p.split(' ', 2) }]
        end

        def env
          { 'DEBIAN_FRONTEND' => 'noninteractive' }
        end
      end
    end
  end
end
