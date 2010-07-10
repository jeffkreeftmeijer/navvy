$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'navvy'
require 'spec'
require 'timecop'
require 'spec/autorun'

Spec::Runner.configure do |config|
end

def job_count
  if defined? Navvy::Job.count
    Navvy::Job.count
  else
    Navvy::Job.all.length
  end
end

def first_job
  Navvy::Job.first
end

class Cow
  def self.speak
    'moo'
  end

  def self.broken
    raise 'this method is broken'
  end
end

module Animals
	class Cow
		def self.speak
			'moo'
		end

		def self.broken
			raise 'this method is broken'
		end
	end
end
