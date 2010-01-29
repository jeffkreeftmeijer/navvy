require 'rubygems'
require 'active_record'

module Navvy
  class Job < ActiveRecord::Base
    class << self
      attr_writer :limit, :keep, :max_attempts
    end

    ##
    # Default limit of jobs to be fetched.
    #
    # @return [Integer] limit

    def self.limit
      @limit || Navvy.configuration.job_limit
    end

    ##
    # If and how long the jobs should be kept.
    #
    # @return [Fixnum, true, false] keep

    def self.keep
      @keep || Navvy.configuration.keep_jobs
    end

    ##
    # How often should a job be retried?
    #
    # @return [Fixnum] max_attempts

    def self.max_attempts
      @max_attempts || Navvy.configuration.max_attempts
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
    # @param [Symbol, String] method_name the name of the method you want to run
    # @param [*] arguments optional arguments you want to pass to the method
    #
    # @return [true, false]

    def self.enqueue(object, method_name, *args)
      options = {}
      if args.last.is_a?(Hash)
        options = args.last.delete(:job_options) || {}
         args.pop if args.last.empty?
      end

      create(
        :object =>      object.to_s,
        :method_name => method_name.to_s,
        :arguments =>   args,
        :priority =>    options[:priority] || 0,
        :parent_id =>   options[:parent_id],
        :run_at =>      options[:run_at] || Time.now,
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
        :order =>         'priority desc, created_at'
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
        if args.empty?
          result = object.constantize.send(method_name)
        else
          result = object.constantize.send(method_name, *args)
        end
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
      update_attributes({
        :completed_at =>  Time.now,
        :return =>        return_value
      })
    end

    ##
    # Mark the job as failed. Will set failed_at to the current time and
    # optionally add the exception message if provided. Also, it will retry
    # the job unless max_attempts has been reached.
    #
    # @param [String] exception the exception message you want to store.
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call

    def failed(message = nil)
      self.retry unless times_failed >= self.class.max_attempts
      update_attributes(
        :failed_at => Time.now,
        :exception => message
      )
    end

    ##
    # Retry the current job. Will add self to the queue again, giving the clone
    # a parend_id equal to self.id.
    #
    # @return [true, false]

    def retry
      self.class.enqueue(
        object,
        method_name,
        *(args << {
          :job_options => {
            :parent_id => parent_id || id,
            :run_at => Time.now + 4 ** times_failed
          }
        })
      )
    end

    ##
    # Check how many times the job has failed. Will try to find jobs with a
    # parent_id that's the same as self.id and count them
    #
    # @return [Integer] count the amount of times the job has failed

    def times_failed
      self.class.count(
        :conditions => "`id` == '#{id}' OR `parent_id` == '#{id}'"
      )
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
      arguments.is_a?(Array) ? arguments : YAML.load(arguments)
    end

    ##
    # Get the job status
    #
    # @return [:pending, :completed, :failed] status

    def status
      return :completed if completed?
      return :failed if failed?
      :pending
    end

    alias_method :completed?, :completed_at?
    alias_method :failed?,    :failed_at?
  end
end
