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
    
    ##
    # Should the job be kept?
    #
    # @return [true, false] keep
    
    def self.keep?
      keep = (@keep || false)
      return keep.from_now >= Time.now if keep.is_a? Fixnum
      keep
    end
  end
end
