require 'wright/provider'

module Wright
  class Provider
    # Public: Package provider. Used as a Provider base class for
    # Resource::Package.
    class Package < Wright::Provider
      # Public: Check if the package is up-to-date for a given
      # action.
      #
      # action - The action symbol. Currently supports :install and
      #          :remove.
      #
      # Returns true if the package is up-to-date and false otherwise.
      # Raises ArgumentError if the action is invalid.
      def uptodate?(action)
        case action
        when :install
          !installed_version.nil?
        when :remove
          installed_version.nil?
        else
          fail ArgumentError, "invalid action '#{action}'"
        end
      end
    end
  end
end
