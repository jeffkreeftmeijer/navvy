require File.expand_path(File.dirname(__FILE__) + '/navvy/job')
require File.expand_path(File.dirname(__FILE__) + '/navvy/worker')
require File.expand_path(File.dirname(__FILE__) + '/navvy/log')
require File.expand_path(File.dirname(__FILE__) + '/navvy/configuration')

module Navvy
  class << self
    attr_writer :configuration
  end
  
  def self.configuration
    @configuration ||= Configuration.new
  end
    
  def self.configure
    yield(self.configuration)
  end
end
