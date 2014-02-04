require 'spec_helper'

describe Navvy::Configuration do
  after do
    Navvy.configure do |config|
      config.job_limit =  100
      config.keep_jobs =  false
      config.logger =     Navvy::Logger.new('/dev/null')
      config.sleep_time = 5
      config.parallel =   false
    end
  end

  it 'should have a job limit of 100 by default' do
    Navvy::Job.limit.should == 100
  end

  it 'should set the job limit' do
    Navvy.configure do |config|
      config.job_limit = 10
    end

    Navvy::Job.limit.should == 10
  end

  it 'should have keep_jobs off by default' do
    Navvy::Job.keep.should == false
  end

  it 'should set keep_jobs' do
    Navvy.configure do |config|
      config.keep_jobs = 10
    end

    Navvy::Job.keep.should == 10
  end

  it 'should set the logger' do
    Navvy.configure do |config|
      config.logger = Navvy::Logger.new
    end

    Navvy.logger.instance_variable_get(:@logdev).filename.should == nil
  end

  it 'should have a default sleep time of 5' do
    Navvy::Worker.sleep_time.should == 5
  end

  it 'should turn quiet off' do
    Navvy.configure do |config|
      config.sleep_time = 10
    end

    Navvy::Worker.sleep_time.should == 10
  end

  it 'should have a default max_attempts of 25' do
    Navvy::Job.max_attempts.should == 25
  end

  it 'should set max_attempts to 15' do
    Navvy.configure do |config|
      config.max_attempts = 15
    end

    Navvy::Job.max_attempts.should == 15
  end
  
  it "should set parallel to true" do
    Navvy.configure do |config|
      config.parallel = true
    end

    Navvy::Job.parallel.should == true
  end
  
end
