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
          cmd_stdout, _cmd_stderr, cmd_status = Open3.capture3(env, cmd)
          installed_re = /^Status: install ok installed$/

          if cmd_status.success? && installed_re =~ cmd_stdout
            /^Version: (?<version>.*)$/ =~ cmd_stdout
            version
          else
            nil
          end
        end

        def install
          if uptodate?(:install)
            Wright.log.debug "package already installed: '#{@resource.name}'"
            return
          end

          install_package
          @updated = true
        end

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
            apt_get_install(package)
          end
        end

        def remove_package
          package = @resource.name
          if Wright.dry_run?
            Wright.log.info "(would) remove package: '#{package}'"
          else
            Wright.log.info "remove package: '#{package}'"
            apt_get_remove(package)
          end
        end

        def apt_get_install(package)
          apt_cmd = "apt-get install -qy #{package}"
          _cmd_stdout, cmd_stderr, cmd_status = Open3.capture3(env, apt_cmd)
          unless cmd_status.success?
            apt_error = cmd_stderr.chomp
            fail %Q(cannot install package '#{package}': "#{apt_error}")
          end
        end

        def apt_get_remove(package)
          apt_cmd = "apt-get remove -qy #{package}"
          _cmd_stdout, cmd_stderr, cmd_status = Open3.capture3(env, apt_cmd)
          unless cmd_status.success?
            apt_error = cmd_stderr.chomp
            fail %Q(cannot remove package '#{package}': "#{apt_error}")
          end
        end

        def env
          { 'DEBIAN_FRONTEND' => 'noninteractive' }
        end
      end
    end
  end
end
