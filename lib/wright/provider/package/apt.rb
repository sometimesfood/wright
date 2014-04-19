require 'wright/provider'
require 'wright/provider/package'

module Wright
  class Provider
    class Package
      # Public: AptPackage provider. Used as a Provider for
      # Resource::Package on Debian-based systems.
      class Apt < Wright::Provider::Package
        def installed_version
          cmd = "dpkg-query -s #{@resource.name}"
          cmd_stdout, _cmd_stderr, cmd_status = Open3.capture3(cmd)
          installed_re = /^Status: install ok installed$/

          if cmd_status.success? && installed_re =~ cmd_stdout
            /^Version: (?<version>.*)$/ =~ cmd_stdout
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
