require 'rubygems'
require 'mongo_mapper'
MongoMapper.database = 'navvy_test'

module Navvy
  class Job
    include MongoMapper::Document
    
    key :failed_at, Time

    ##
    # Add a job to the job queue
    #
    # @param [Object] object you want to run a method from
    # @param [Symbol, String] name of the method you want to run
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
    # @return [Navvy::Job, nil] next available job or nil if no jobs were found

    def self.next
      first(:failed_at => nil)
    end

    ##
    # Run a job
    #
    # @example
    #   job = Navvy::Job.next # finds the next available job in the queue
    #   job.run               # runs the job and returns the job's return value
    #
    # @return [String] return value of the called method

    def run
      begin
        result = object.constantize.send(method)
        destroy
        result
      rescue Exception => exception
        update_attributes({
          :exception => exception.message,
          :failed_at => Time.now
        })
      end
    end
  end
end
