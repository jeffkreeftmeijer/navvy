require 'sequel'
require 'yaml'

module Navvy
  class Job < Sequel::Model

    ##
    # Add a job to the job queue.
    #
    # @param [Object] object the object you want to run a method from
    # @param [Symbol, String] method_name the name of the method you want to
    # run
    # @param [*] arguments optional arguments you want to pass to the method
    #
    # @return [Job, false] created Job or false if failed

    def self.enqueue(object, method_name, *args)
      options = {}
      if args.last.is_a?(Hash)
        options = args.last.delete(:job_options) || {}
        args.pop if args.last.empty?
      end

      Job[insert(
        :object =>      object.to_s,
        :method_name => method_name.to_s,
        :arguments =>   args.to_yaml,
        :priority =>    options[:priority] || 0,
        :parent_id =>   options[:parent_id],
        :run_at =>      options[:run_at] || Time.now,
        :created_at =>  Time.now
      )]
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
      filter(:failed_at => nil).
        filter(:completed_at => nil).
        filter{run_at <= Time.now}.
        order(:priority.desc, :created_at).
        first(limit)
    end

    ##
    # Clean up jobs that we don't need to keep anymore. If Navvy::Job.keep is
    # false it'll delete every completed job, if it's a timestamp it'll only
    # delete completed jobs that have passed their keeptime.
    #
    # @return [true, false] delete_all the result of the delete_all call

    def self.cleanup
      if keep.is_a? Fixnum
        time = Time.now - keep
        filter{completed_at <= time}.delete
      else
        filter(~{:completed_at => nil}).delete unless keep?
      end
    end

    ##
    # Deletes all jobs.
    #
    # @return [Integer] amount the amount of jobs that were deleted

    def self.delete_all
      Navvy::Job.destroy
    end

    ##
    # Mark the job as started. Will set started_at to the current time.
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call

    def started
      update(:started_at =>  Time.now)
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
      update(
        :completed_at =>  Time.now,
        :return =>        return_value
      )
    end

    ##
    # Mark the job as failed. Will set failed_at to the current time and
    # optionally add the exception message if provided. Also, it will retry
    # the job unless max_attempts has been reached or retryable is false.
    #
    # @param [String] exception the exception message you want to store.
    # @param [true, false] whether or not to attempt to retry the job
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call

    def failed(message = nil, retryable = true)
      self.retry unless !retryable || times_failed >= self.class.max_attempts
      update(
        :failed_at => Time.now,
        :exception => message
      )
    end

    ##
    # Check how many times the job has failed. Will try to find jobs with a
    # parent_id that's the same as self.id and count them
    #
    # @return [Integer] count the amount of times the job has failed

    def times_failed
      i = parent_id || id
      self.class.filter({:id => i} | {:parent_id => i}).
        filter(~{:failed_at => nil}).
        count
    end
  end
end

require 'navvy/job'
