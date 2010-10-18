require 'navvy/worker'
require 'navvy/logger'
require 'navvy/configuration'

module Navvy
  class << self
    attr_writer :configuration
  end

  def self.logger
    @logger || Navvy.configuration.logger
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(self.configuration)
  end
end
