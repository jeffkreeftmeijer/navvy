require 'rubygems'
require 'dm-core'
require 'dm-aggregates'

module Navvy
  class Job
    include DataMapper::Resource

    property :id,            Serial
    property :object,        String
    property :method_name,   String
    property :arguments,     String
    property :priority,      Integer, :default => 0
    property :return,        String
    property :exception,     String
    property :parent_id,     Integer
    property :created_at,    Time
    property :run_at,        Time
    property :started_at,    Time
    property :completed_at,  Time
    property :failed_at,     Time

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
      options = {}
      if args.last.is_a?(Hash)
        options = args.last.delete(:job_options) || {}
        args.pop if args.last.empty?
      end

      new_job = self.new
      new_job.attributes = {
        :object =>      object.to_s,
        :method_name => method_name.to_s,
        :arguments =>   args.to_yaml,
        :priority =>    options[:priority] || 0,
        :parent_id =>   options[:parent_id],
        :run_at =>      options[:run_at] || Time.now,
        :created_at =>  Time.now
      }
      new_job.save
      new_job
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
        :failed_at =>     nil,
        :completed_at =>  nil,
        :run_at.lte =>    Time.now,
        :order =>         [:priority.desc, :created_at.asc],
        :limit =>         limit
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
        all(:completed_at.lte => (Time.now - keep)).destroy
      else
        all(:completed_at.not => nil ).destroy unless keep?
      end
    end

    def self.count(*args)
      case args.first
      when :pending
        all(
          :failed_at => nil,
          :completed_at => nil
        ).count
      when :completed
        all(
          :completed_at.not => nil
        ).count
      when :failed
        all(
          :failed_at.not => nil
        ).count
      else
        super(*args)
      end
    end

    ##
    # Mark the job as started. Will set started_at to the current time.
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call

    def started
      update({
        :started_at =>  Time.now
      })
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
    # the job unless max_attempts has been reached.
    #
    # @param [String] exception the exception message you want to store.
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call

    def failed(message = nil)
      self.retry unless times_failed >= self.class.max_attempts
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
      self.class.all(
        :conditions => ["(`id` = ? OR `parent_id` = ?) AND `failed_at` IS NOT NULL", i, i]
      ).count
    end
  end
end
