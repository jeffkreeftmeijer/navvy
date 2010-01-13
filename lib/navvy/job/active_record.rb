require 'rubygems'
require 'active_record'

module Navvy
  class Job < ActiveRecord::Base
    class << self
      attr_writer :limit
      attr_accessor :keep
    end

    ##
    # Default limit of jobs to be fetched
    #
    # @return [Integer] limit

    def self.limit
      @limit || 100
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

    ##
    # Add a job to the job queue.
    #
    # @param [Object] object the object you want to run a method from
    # @param [Symbol, String] method the name of the method you want to run
    # @param [*] arguments optional arguments you want to pass to the method
    #
    # @return [true, false]

    def self.enqueue(object, method, *args)
      create(
        :object =>      object.name,
        :method =>      method.to_s,
        :arguments =>   args,
        :run_at =>      Time.now,
        :created_at =>  Time.now
      )
    end

    ##
    # Find the next available jobs in the queue. This will not include failed
    # jobs (where :failed_at is not nil) and jobs that should run in the future
    # (where :run_at is greater than the current time).
    #
    # @param [Integer] limit the limit of jobs to be fetched. Defaults to
    # Navvy::Job.limit
    #
    # @return [array, nil] the next available jobs in an array or nil if no
    # jobs were found.

    def self.next(limit = self.limit)
      all(
        :conditions =>    [
          '`failed_at` IS NULL AND `completed_at` IS NULL AND `run_at` <= ?',
          Time.now
        ],
        :limit =>         limit,
        :order =>         'created_at'
      )
    end

    ##
    # Clean up jobs that we don't need to keep anymore. If Navvy::Job.keep is
    # false it'll delete every completed job, if it's a timestamp it'll only
    # delete completed jobs that have passed their keeptime.
    #
    # @return [true, false] delete_all the result of the delete_all call

    def self.cleanup
      if keep.is_a? Fixnum
        delete_all([
          '`completed_at` <= ?',
          keep.ago
        ])
      else
        delete_all(
          '`completed_at` IS NOT NULL'
        ) unless keep?
      end
    end
    
    ##
    # Run the job. Will delete the Navvy::Job record and return its return
    # value if it runs successfully unless Navvy::Job.keep is set. If a job
    # fails, it'll update the Navvy::Job record to include the exception
    # message it sent back and set the :failed_at date. Failed jobs never get
    # deleted.
    #
    # @example
    #   job = Navvy::Job.next # finds the next available job in the queue
    #   job.run               # runs the job and returns the job's return value
    #
    # @return [String] return value of the called method.

    def run
      begin
        update_attributes(:started_at => Time.now)
        result = object.constantize.send(method)
        Navvy::Job.keep? ? completed : destroy
        result
      rescue Exception => exception
        failed(exception.message)
      end
    end
  end
end
