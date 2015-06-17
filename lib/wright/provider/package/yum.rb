require 'open3'

require 'wright/provider'
require 'wright/provider/package'

module Wright
  class Provider
    class Package
      # Yum package provider. Used as a provider for
      # {Resource::Package} on Fedora-based systems.
      class Yum < Wright::Provider::Package
        # @return [Array<String>] the installed package versions
        def installed_versions
          version_format = '%{VERSION}-%{RELEASE}'
          rpm_args = %W(-q #{package_name} --qf #{version_format})
          stdout, _, status = Open3.capture3(env, 'rpm', *rpm_args)
          status.success? ? [stdout] : []
        end

        private

        def install_package
          yum(:install, package_options, package_name, package_version)
        end

        def remove_package
          yum(:remove, package_options, package_name)
        end

        def yum(action, options, package, version = nil)
          cmd = 'yum'
          package_version = version.nil? ? '' : "-#{version}"
          args = ['-y', *options, action.to_s, package + package_version]
          exec_or_fail(cmd, args, "cannot #{action} package '#{package}'")
        end
      end
    end
  end
end
