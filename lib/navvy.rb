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


if defined?(Rails)

  module Navvy
    class Railtie < Rails::Railtie
      rake_tasks do
        require 'navvy/tasks.rb'
      end
    end
  end

end
