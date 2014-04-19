require 'wright/provider'
require 'wright/provider/package'

module Wright
  class Provider
    class Package
      # Public: AptPackage provider. Used as a Provider for
      # Resource::Package on Debian-based systems.
      class Apt < Wright::Provider::Package
        def installed_version
          package = @resource.name
          stdout, stderr, status = Open3.capture3("dpkg-query -s #{package}")
          if status.success?
            /^Version: (?<version>.*)$/ =~ stdout
            version
          else
            nil
          end
        end

        def install
          if uptodate?
            Wright.log.debug "package already installed: '#{@resource.name}'"
            return
          end

          install_package
          @updated = true
        end

        private

        def install_package
          if Wright.dry_run?
            Wright.log.info "(would) install package: '#{@resource.name}'"
          else
            Wright.log.info "install package: '#{@resource.name}'"
            # TODO: actually install package
          end
        end
      end
    end
  end
end
