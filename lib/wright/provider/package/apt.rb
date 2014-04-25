require 'open3'

require 'wright/dry_run'
require 'wright/provider'
require 'wright/provider/package'

module Wright
  class Provider
    class Package
      # Public: AptPackage provider. Used as a Provider for
      # Resource::Package on Debian-based systems.
      class Apt < Wright::Provider::Package
        # Public: Get the installed package version.
        #
        # Returns the package version String or nil if the package is
        # not currently installed.
        def installed_version
          cmd = "dpkg-query -s #{@resource.name}"
          cmd_stdout, _cmd_stderr, cmd_status = Open3.capture3(env, cmd)
          installed_re = /^Status: install ok installed$/

          if cmd_status.success? && installed_re =~ cmd_stdout
            /^Version: (?<version>.*)$/ =~ cmd_stdout
            version
          else
            nil
          end
        end

        # Public: Install the package.
        #
        # Returns nothing.
        def install
          if uptodate?(:install)
            Wright.log.debug "package already installed: '#{@resource.name}'"
            return
          end

          install_package
          @updated = true
        end

        # Public: Remove the package.
        #
        # Returns nothing.
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
          if Wright.dry_run?
            Wright.log.info "(would) install package: '#{package}'"
          else
            Wright.log.info "install package: '#{package}'"
            apt_get(:install, package, @resource.version)
          end
        end

        def remove_package
          package = @resource.name
          if Wright.dry_run?
            Wright.log.info "(would) remove package: '#{package}'"
          else
            Wright.log.info "remove package: '#{package}'"
            apt_get(:remove, package)
          end
        end

        def apt_get(action, package, version = nil)
          package_version = version.nil? ? '' : "=#{version}"
          apt_cmd = "apt-get #{action} -qy #{package}#{package_version}"
          _cmd_stdout, cmd_stderr, cmd_status = Open3.capture3(env, apt_cmd)
          unless cmd_status.success?
            apt_error = cmd_stderr.chomp
            fail %Q(cannot #{action} package '#{package}': "#{apt_error}")
          end
        end

        def env
          { 'DEBIAN_FRONTEND' => 'noninteractive' }
        end
      end
    end
  end
end
