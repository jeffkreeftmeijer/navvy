require 'rubygems'
require 'mongo_mapper'

module Navvy
  class Job
    include MongoMapper::Document
    key :error, String
    
    ##
    # Add a job to the job queue
    #
    # @param [Object] the object you want to run a method from
    # @param [Symbol, String] the name of the method you want to run
    # @param [*] optional arguments you want to pass to the method
    #
    # @return [true, false]

    def self.enqueue(object, method, *args)
      create(
        :object =>    object.name,
        :method =>    method.to_sym,
        :arguments => args
      )
    end
    
    ##
    # Find the next available job in the queue
    #
    # @return [Navvy::Job]
    
    def self.next
      first
    end
    
    ##
    # Run a job
    #                                                       
    # @example
    #   job = Navvy::Job.next # finds the next available job in the queue
    #   job.run               # runs the job and returns the job's return value
    #
    # @return [String] the return value of the called method
    
    def run
      result = object.constantize.send(method)
      destroy
      result
    end
  end
end
