module Wright
  module Util
    # Internal: ANSI color helpers.
    module Color
      # Internal: Colorize a string (red).
      #
      # string - The string to colorize.
      #
      # Returns the colorized String.
      def self.red(string)
        colorize(string, :red)
      end

      # Internal: Colorize a string (yellow).
      #
      # string - The string to colorize.
      #
      # Returns the colorized String.
      def self.yellow(string)
        colorize(string, :yellow)
      end

      # Internal: Colorize a string.
      #
      # string - The string to colorize.
      # color - The color that should be used.
      #
      # Examples
      #
      #   Wright::Util::Color.colorize('Hello world', :red)
      #   # => "\e[31mHello world\e[0m"
      #
      #   Wright::Util::Color.colorize('Hello world', :yellow)
      #   # => "\e[32mHello world\e[0m"
      #
      # Returns the colorized String.
      def self.colorize(string, color)
        no_color = COLOR_MAP[:none]
        color = COLOR_MAP.fetch(color, no_color)
        "#{color}#{string}#{no_color}"
      end

      COLOR_MAP = { #:nodoc:
        none: "\e[0m",
        red: "\e[31m",
        yellow: "\e[32m"
      }
      private_constant :COLOR_MAP
    end
  end
end
