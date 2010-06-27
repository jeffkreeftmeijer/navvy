require 'logger'

module Navvy
  class Logger < Logger
    ##
    # Create a new logger. Works like Logger from Ruby's standard library, but
    # defaults to STDOUT instead of failing. You can pass a filename to log to.
    #
    # @param [String] logdev a filename to log to, defaults to STDOUT
    #
    # @example
    #   logger = Navvy::Logger.new
    #   logger = Navvy::Logger.new('~/file.log')

    def initialize(logdev = STDOUT)
      super logdev
    end

    ##
    # Send colored logs to the logger. Will only colorize output sent to
    # STDOUT and will call the regular info method when writing to file.
    #
    # @param [String] message the message you want to log
    # @param [String] color the color code you want to use to color your
    # message
    #
    # @example
    #   logger = Navvy::Logger.new
    #   logger.colorized_info "I'm green!", 32

    def colorized_info(message, color)
      unless @logdev.filename
        return info("\e[#{color}m#{message}\e[0m")
      end
      info(message)
    end
  end
end
