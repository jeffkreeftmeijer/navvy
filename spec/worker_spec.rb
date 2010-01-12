require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Navvy::Worker do
  describe '.fetch_and_run_jobs' do
    before do
      @jobs = [
        Navvy::Job.enqueue(Cow, :speak),
        Navvy::Job.enqueue(Cow, :speak),
        Navvy::Job.enqueue(Cow, :speak)
      ]

      Navvy::Job.stub!(:next).and_return(@jobs)
    end

    it 'should fetch jobs' do
      Navvy::Job.should_receive(:next).and_return(@jobs)
      Navvy::Worker.fetch_and_run_jobs
    end

    it 'should run three jobs' do
      @jobs.each do |job|
        job.should_receive(:run)
      end
      Navvy::Worker.fetch_and_run_jobs
    end
  end
end
