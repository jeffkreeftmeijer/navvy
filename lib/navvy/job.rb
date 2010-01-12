module Navvy
  class Job
    class << self
      attr_accessor :limit, :keep
    end
    
    ##
    # Default limit of jobs to be fetched
    #
    # @return [Integer] limit
    
    def self.limit
      @limit || 10
    end
  end
end