require 'open3'

require 'wright/provider'
require 'wright/provider/package'

module Wright
  class Provider
    class Package
      # Yum package provider. Used as a provider for
      # {Resource::Package} on Fedora-based systems.
      #
      # @todo implement #install_package
      # @todo implement #remove_package
      class Yum < Wright::Provider::Package
        # @return [Array<String>] the installed package versions
        def installed_versions
          version_format = '%{VERSION}-%{RELEASE}'
          rpm_args = %W(-q #{package_name} --qf #{version_format})
          stdout, _, status = Open3.capture3(env, 'rpm', *rpm_args)
          status.success? ? [stdout] : []
        end
      end
    end
  end
end
