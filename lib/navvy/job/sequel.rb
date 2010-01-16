require 'rubygems'
require 'sequel'
require 'yaml'

module Navvy
  class Job < Sequel::Model
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
      return (Time.now + keep) >= Time.now if keep.is_a? Fixnum
      keep
    end

    ##
    # Add a job to the job queue.
    #
    # @param [Object] object the object you want to run a method from
    # @param [Symbol, String] method_name the name of the method you want to 
    # run
    # @param [*] arguments optional arguments you want to pass to the method
    #
    # @return [true, false]

    def self.enqueue(object, method_name, *args)
      create(
        :object =>      object.to_s,
        :method_name => method_name.to_s,
        :arguments =>   YAML::dump(args),
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
      filter(
        '`failed_at` IS NULL AND `completed_at` IS NULL AND `run_at` <= ?',
        Time.now
      ).order(:created_at).first(limit)
    end

    ##
    # Clean up jobs that we don't need to keep anymore. If Navvy::Job.keep is
    # false it'll delete every completed job, if it's a timestamp it'll only
    # delete completed jobs that have passed their keeptime.
    #
    # @return [true, false] delete_all the result of the delete_all call

    def self.cleanup
      if keep.is_a? Fixnum
        filter('`completed_at` <= ?', (Time.now - keep)).delete
      else
        filter('`completed_at` IS NOT NULL').delete unless keep?
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
        update(:started_at => Time.now)
        result = Kernel.const_get(object).send(method_name, *args)
        Navvy::Job.keep? ? completed : destroy
        result
      rescue Exception => exception
        failed(exception.message)
      end
    end
    
    ##
    # Mark the job as completed. Will set completed_at to the current time and 
    # optionally add the return value if provided.
    #
    # @param [String] return_value the return value you want to store.
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call
    
    def completed(return_value = nil)
      update({
        :completed_at =>  Time.now,
        :return =>        return_value
      })
    end
    
    ##
    # Mark the job as failed. Will set failed_at to the current time and 
    # optionally add the exception message if provided.
    #
    # @param [String] exception the exception message you want to store.
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call
    
    def failed(message = nil)
      update({
        :failed_at => Time.now,
        :exception => message
      })
    end
    
    ##
    # Check if the job has been run. 
    #
    # @return [true, false] ran
    
    def ran?
      completed? || failed?
    end
    
    ##
    # Check how long it took for a job to complete or fail
    #
    # @return [Time, Integer] time the time it took
    
    def duration
      ran? ? (completed_at || failed_at) - started_at : 0
    end
    
    ##
    # Check if completed_at is set
    #
    # @return [true, false] set?
    
    def completed_at?
      !completed_at.nil?
    end

    ##
    # Check if failed_at is set
    #
    # @return [true, false] set?
    
    def failed_at?
      !failed_at.nil?
    end
    
    ##
    # Get the job arguments as an array
    #
    # @return [array] arguments
    
    def args
      arguments.first.is_a?(Array) ? arguments : YAML.load(arguments)
    end
    
    alias_method :completed?, :completed_at?
    alias_method :failed?,    :failed_at?
  end
end
