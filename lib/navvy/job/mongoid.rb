require 'mongoid'

module Navvy
  class Job
    include Mongoid::Document
    include Mongoid::Timestamps

    field :object,        :type => String
    field :method_name,   :type => String
    field :arguments,     :type => String
    field :priority,      :type => Integer, :default => 0
    field :return,        :type => String
    field :exception,     :type => String
    field :parent_id,     :type => BSON::ObjectId
    field :created_at,    :type => Time
    field :run_at,        :type => Time
    field :started_at,    :type => Time
    field :completed_at,  :type => Time
    field :failed_at,     :type => Time

    index [[:priority, Mongo::DESCENDING]]
    index [[:created_at, Mongo::ASCENDING]]

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

      create(
        :object =>      object.to_s,
        :method_name => method_name.to_sym,
        :arguments =>   args.to_yaml,
        :priority =>    options[:priority] || 0,
        :parent_id =>   options[:parent_id],
        :run_at =>      options[:run_at] || Time.now
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
      where(:failed_at => nil).
        where(:completed_at => nil).
        where(:run_at.lte => Time.now).
        order_by([[:priority, :desc], [:created_at, :asc]]).
        limit(limit).to_a
    end

    ##
    # Clean up jobs that we don't need to keep anymore. If Navvy::Job.keep is
    # false it'll delete every completed job, if it's a timestamp it'll only
    # delete completed jobs that have passed their keeptime.
    #
    # @return [true, false] delete_all the result of the delete_all call

    def self.cleanup
      if keep.is_a? Fixnum
        destroy_all(:conditions => { :completed_at.lte => keep.ago })
      else
        destroy_all(:conditions => { :completed_at.ne => nil }) unless keep?
      end
    end

    ##
    # Mark the job as started. Will set started_at to the current time.
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call

    def started
      update_attributes(:started_at =>  Time.now)
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
      update_attributes(:completed_at => Time.now, :return => return_value)
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
      update_attributes(:failed_at => Time.now, :exception => message)
    end

    ##
    # Check how many times the job has failed. Will try to find jobs with a
    # parent_id that's the same as self.id and count them
    #
    # @return [Integer] count the amount of times the job has failed

    def times_failed
      i = parent_id || id
      self.class.
        where(:failed_at.ne => nil).
        where("this._id == '#{i}' || this.parent_id == '#{i}'").
        count
    end
  end
end

require 'navvy/job'
