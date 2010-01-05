require 'rubygems'
require 'mongo_mapper'

module Navvy
  class Job
    include MongoMapper::Document
    
    ## 
    # Add a job to the job queue
    # 
    # @param [Object] the object you want to run a method from
    # @param [Symbol, String] the name of the method you want to run
    # @parem [*] optional arguments you want to pass to the method
    #
    # @return [true, false]
    
    def self.enqueue(object, method, *args)
      create(
        :object =>    object.name,
        :method =>    method.to_sym,
        :arguments => args
      )
    end
  end
end
  