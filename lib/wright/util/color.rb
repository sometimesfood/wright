module Wright
  module Util
    # ANSI color helpers.
    module Color
      # Colorizes a string (red).
      #
      # @param string [String] the string to colorize
      #
      # @return [String] the colorized string
      def self.red(string)
        colorize(string, :red)
      end

      # Colorizes a string (yellow).
      #
      # @param string [String] the string to colorize
      #
      # @return [String] the colorized string
      def self.yellow(string)
        colorize(string, :yellow)
      end

      # Colorizes a string.
      #
      # @param string [String] the string to colorize
      # @param color [String] the color that should be used
      #
      # @example
      #   Wright::Util::Color.colorize('Hello world', :red)
      #   # => "\e[31mHello world\e[0m"
      #
      #   Wright::Util::Color.colorize('Hello world', :yellow)
      #   # => "\e[32mHello world\e[0m"
      #
      # @return [String] the colorized string
      def self.colorize(string, color)
        no_color = COLOR_MAP[:none]
        color = COLOR_MAP.fetch(color, no_color)
        "#{color}#{string}#{no_color}"
      end

      COLOR_MAP = {
        none: "\e[0m",
        red: "\e[31m",
        yellow: "\e[33m"
      }
      private_constant :COLOR_MAP
    end
  end
end
