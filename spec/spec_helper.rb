require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'navvy'
require 'spec'
require 'timecop'
require 'spec/autorun'


Spec::Runner.configure { |config| }


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
