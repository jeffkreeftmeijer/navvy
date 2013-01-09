# Sorry for the naming, otherwise rspec executes this file too early

require "spec_helper"
require "date"

# extend class Job
module SequelHooks
	module InstanceMethods
		def before_create
			puts "Job is created"
		end

		def after_update
			puts "Job is updated"
		end

		def after_destroy
			puts "Job is gone"
		end
	end
end

Navvy::Job.plugin( SequelHooks )

# test

describe "when Job is created" do
	it "should output that it's created" do
		Navvy::Job.enqueue( Cow, :speak)
	end
end

describe "when Job is updated" do
	it "should output that it's updated" do
		Navvy::Job.enqueue( Cow, :speak )
		job = first_job
		job.failed_at = DateTime.now
	end
end

describe "when job is destroyed" do
	it "should output that it's destroyed" do
		Navvy::Job.enqueue( Cow, :speak )
		job = first_job
		job.destroy
	end
end