require 'spec_helper'

describe 'Navvy::Job' do
  before do
    Timecop.freeze(Time.local(2010, 1, 1))
  end

  after do
    Timecop.return
  end

  describe '.keep?' do
    after(:each) do
      Navvy::Job.keep = false
      Navvy.configure do |config|
        config.keep_jobs = false
      end
    end

    describe 'when configured using Navvy::Job.keep=' do
      it 'should return false' do
        Navvy::Job.keep = false
        Navvy::Job.keep?.should == false
      end

      it 'should return true' do
        Navvy::Job.keep = true
        Navvy::Job.keep?.should == true
      end
    end

    describe 'when configured with Navvy.configure' do
      it 'should return false' do
        Navvy.configure do |config|
          config.keep_jobs = false
        end
        Navvy::Job.keep?.should == false
      end

      it 'should return true' do
        Navvy.configure do |config|
          config.keep_jobs = true
        end
        Navvy::Job.keep?.should == true
      end
    end
  end

  describe '.enqueue' do
    before(:each) do
      Navvy::Job.delete_all
    end

    it 'should enqueue a job' do
      Navvy::Job.enqueue(Cow, :speak)
      job_count.should == 1
    end

    it 'should set the object and the method_name' do
      Navvy::Job.enqueue(Cow, :speak)
      job = first_job
      job.object.should == 'Cow'
      job.method_name.to_s.should == 'speak'
    end

    it 'should turn the method_name into a symbol' do
      Navvy::Job.enqueue(Cow, 'speak')
      job = first_job
      job.method_name.to_s.should == 'speak'
    end

    it 'should set the arguments' do
      Navvy::Job.enqueue(Cow, :speak, true, false)
      job = first_job
      job.args.should == [true, false]
    end

    it 'should set the created_at date' do
      Navvy::Job.enqueue(Cow, :speak, true, false)
      job = first_job
      job.created_at.should == Time.now
    end

    it 'should set the run_at date' do
      Navvy::Job.enqueue(Cow, :speak, true, false)
      job = first_job
      job.run_at.should == Time.now
      job.created_at.should == Time.now
    end

    it 'should return the enqueued job' do
      Navvy::Job.enqueue(Cow, :speak, true, false).
        should be_instance_of Navvy::Job
    end
  end

  describe '.next' do
    before(:each) do
      Navvy::Job.delete_all
      Navvy::Job.create(
        :object =>      'Cow',
        :method_name => :last,
        :created_at =>  Time.now + (60 * 60),
        :run_at =>      Time.now
      )
      Navvy::Job.create(
        :object =>        'Cow',
        :method_name =>   :break,
        :completed_at =>  Time.now,
        :run_at =>        Time.now
      )
      Navvy::Job.create(
        :object =>      'Cow',
        :method_name => :break,
        :failed_at =>   Time.now,
        :run_at =>      Time.now
      )
      Navvy::Job.create(
        :object =>      'Cow',
        :method_name => :tomorrow,
        :run_at =>      Time.now + (60 * 60)
      )
      120.times do
        Navvy::Job.enqueue(Cow, :speak)
      end
    end

    it 'should find the next 10 available jobs' do
      jobs = Navvy::Job.next
      jobs.length.should == 100
      jobs.each do |job|
        job.should be_instance_of Navvy::Job
        job.method_name.to_s.should == 'speak'
      end
    end

    it 'should find the next 2 available jobs' do
      Navvy::Job.next(2).length.should == 2
    end

    it 'should find the next 4 available jobs' do
      Navvy::Job.limit = 4
      Navvy::Job.next.length.should == 4
    end
  end

  describe "parallel .next" do
    before(:each) do
      Navvy.configure do |config|
        config.parallel = true
      end

      Navvy::Job.delete_all
      Navvy::Job.create(
        :object =>      'Cow',
        :method_name => :last,
        :created_at =>  Time.now + (60 * 60),
        :run_at =>      Time.now
      )
      Navvy::Job.create(
        :object =>        'Cow',
        :method_name =>   :break,
        :completed_at =>  Time.now,
        :run_at =>        Time.now
      )
      Navvy::Job.create(
        :object =>      'Cow',
        :method_name => :break,
        :failed_at =>   Time.now,
        :run_at =>      Time.now
      )
      Navvy::Job.create(
        :object =>      'Cow',
        :method_name => :tomorrow,
        :run_at =>      Time.now + (60 * 60)
      )
      120.times do
        Navvy::Job.enqueue(Cow, :speak)
      end
    end

    after(:each) do
      Navvy.configure do |config|
        config.parallel = false
      end
    end

    it "should return the next 1 available job" do
      Navvy::Job.next.length.should == 1
    end

    it "should mark the job as started" do
      Navvy::Job.next[0].started_at.should_not be_nil
    end

    it "should ignore job length" do
      Navvy::Job.next(100).length.should == 1
    end
  end

  describe '.cleanup' do
    before(:each) do
      Navvy::Job.delete_all
      Navvy::Job.create(
        :object =>        'Cow',
        :method_name =>   :speak,
        :completed_at =>  Time.now - (2 * 60 * 60)
      )
      Navvy::Job.create(
        :object =>        'Cow',
        :method_name =>   :speak,
        :completed_at =>  Time.now
      )
      Navvy::Job.create(
        :object =>      'Cow',
        :method_name => :speak
      )
    end

    it 'should delete all complete jobs when "keep" is false' do
      Navvy::Job.cleanup
      job_count.should == 1
    end

    it 'should not delete any complete jobs when "keep" is true' do
      Navvy::Job.keep = true
      Navvy::Job.cleanup
      job_count.should == 3
    end

    it 'should delete all complete jobs where "keep" has passed' do
      Navvy::Job.keep = (60 * 60)
      Navvy::Job.cleanup
      job_count.should == 2
    end
  end

  describe '.delete_all' do
    it 'should delete all jobs' do
      3.times do; Navvy::Job.create; end
      Navvy::Job.delete_all
      job_count.should == 0
    end
  end

  describe '#run' do
    it 'should pass the arguments' do
      Navvy::Job.delete_all
      job = Navvy::Job.enqueue(Cow, :name, 'Betsy')
      Cow.should_receive(:name).with('Betsy')
      job.run
    end

    describe 'when everything goes well' do
      before(:each) do
        Navvy::Job.delete_all
        Navvy::Job.enqueue(Cow, :speak)
        Navvy::Job.keep = false
      end

      it 'should run the job and delete it' do
        jobs = Navvy::Job.next
        jobs.first.run.should == '"moo"'
        job_count.should == 0
      end

      describe 'when Navvy::Job.keep is set' do
        it 'should call #completed with the return value after processing the job' do
          Navvy::Job.keep = true
          jobs = Navvy::Job.next
          jobs.first.should_receive(:completed).with('"moo"')
          jobs.first.run
        end

        it 'should mark the job as complete when keep is true' do
          Navvy::Job.keep = true
          jobs = Navvy::Job.next
          jobs.first.run
          job_count.should == 1
          jobs.first.started_at.should == Time.now
          jobs.first.completed_at.should == Time.now
        end

        it 'should mark the job as complete when keep has not passed yet' do
          Navvy::Job.keep = (60 * 60)
          jobs = Navvy::Job.next
          jobs.first.run
          job_count.should == 1
          jobs.first.started_at.should == Time.now
          jobs.first.completed_at.should == Time.now
        end

        it 'should delete the job when the "keep" flag has passed' do
          Navvy::Job.keep = -(60 * 60)
          jobs = Navvy::Job.next
          jobs.first.run
          job_count.should == 0
        end
      end
    end

    describe 'when a job fails' do

      describe 'with a standard exception' do

        before(:each) do
          Navvy::Job.delete_all
          Navvy::Job.enqueue(Cow, :broken)
        end

        it 'should store the exception and current time' do
          jobs = Navvy::Job.next
          jobs.first.run
          jobs.first.exception.should == 'this method is broken'
          jobs.first.started_at.should == Time.now
          jobs.first.failed_at.should == Time.now
        end

        it 'should call Job#failed with the exception message' do
          jobs = Navvy::Job.next
          jobs.first.should_receive(:failed).with('this method is broken')
          jobs.first.run
        end
      end

      describe 'with a Navvy::Job::NoRetryException' do

        before(:each) do
          Navvy::Job.delete_all
          Navvy::Job.enqueue(Cow, :broken_no_retry)
        end

        it 'should store the exception and current time' do
          jobs = Navvy::Job.next
          jobs.first.run
          jobs.first.exception.should == 'this method is broken with no retry'
          jobs.first.started_at.should == Time.now
          jobs.first.failed_at.should == Time.now
        end

        it 'should call Job#failed with the exception message and no retry' do
          jobs = Navvy::Job.next
          jobs.first.should_receive(:failed).with('this method is broken with no retry', false)
          jobs.first.run
        end
      end
    end
  end

  describe '#started' do
    before(:each) do
      Navvy::Job.delete_all
      Navvy::Job.enqueue(Cow, :speak)
    end

    it 'should update the jobs started_at date' do
      jobs = Navvy::Job.next
      jobs.first.started
      jobs.first.started_at.should_not be_nil
    end
  end

  describe '#completed' do
    before(:each) do
      Navvy::Job.delete_all
      Navvy::Job.enqueue(Cow, :speak)
    end

    it 'should update the jobs completed_at date' do
      jobs = Navvy::Job.next
      jobs.first.completed
      jobs.first.completed_at.should_not be_nil
    end

    it 'should set the return if provided' do
      jobs = Navvy::Job.next
      jobs.first.completed('woo!')
      jobs.first.return.should == 'woo!'
    end
  end

  describe '#failed' do
    before(:each) do
      Navvy::Job.delete_all
      Navvy::Job.enqueue(Cow, :speak)
    end

    it 'should update the jobs failed_at date' do
      jobs = Navvy::Job.next
      jobs.first.failed
      jobs.first.failed_at.should_not be_nil
    end

    it 'should set the exception message if provided' do
      jobs = Navvy::Job.next
      jobs.first.failed('broken')
      jobs.first.exception.should == 'broken'
    end

    it 'should retry' do
      jobs = Navvy::Job.next
      jobs.first.should_receive(:retry)
      jobs.first.failed('broken')
    end

    it 'should not retry when the job has failed 25 times already' do
      jobs = Navvy::Job.next
      jobs.first.stub!(:times_failed).and_return 25
      jobs.first.should_not_receive(:retry)
      jobs.first.failed('broken')
    end

    it 'should not retry when the job has failed 10 times' do
      Navvy::Job.max_attempts = 10
      jobs = Navvy::Job.next
      jobs.first.stub!(:times_failed).and_return 10
      jobs.first.should_not_receive(:retry)
      jobs.first.failed('broken')
    end

    it 'should not retry if retryable is false' do
      jobs = Navvy::Job.next
      jobs.first.should_not_receive(:retry)
      jobs.first.failed('broken', false)
    end
  end

  describe '#retry' do
    before(:each) do
      Navvy::Job.delete_all
    end

    it 'should enqueue a child for the failed job' do
      failed_job = Navvy::Job.enqueue(Cow, :speak, true, false)
      job = failed_job.retry
      job.object.should ==            'Cow'
      job.method_name.to_s.should ==  'speak'
      job.args.should ==              [true, false]
      job.parent_id.should ==         failed_job.id
    end

    it 'should handle hashes correctly' do
      failed_job = Navvy::Job.enqueue(Cow, :speak, 'name' => 'Betsy')
      job = failed_job.retry
      job.args.should ==      [{'name' => 'Betsy'}]
      job.parent_id.should == failed_job.id
    end

    it 'should set the priority' do
      failed_job = Navvy::Job.enqueue(
        Cow,
        :speak,
        'name' => 'Betsy',
        :job_options => {
          :priority => 2
        }
      )
      job = failed_job.retry
      job.priority.should == 2
    end

    it 'should set the run_at date to about 16 seconds from now' do
      failed_job = Navvy::Job.enqueue(Cow, :speak, 'name' => 'Betsy')
      failed_job.stub!(:times_failed).and_return 2
      job = failed_job.retry
      job.run_at.to_i.should == (Time.now + 16).to_i
    end

    it 'should set the run_at date to about 256 seconds from now' do
      failed_job = Navvy::Job.enqueue(Cow, :speak, 'name' => 'Betsy')
      failed_job.stub!(:times_failed).and_return 4
      job = failed_job.retry
      job.run_at.to_i.should == (Time.now + 256).to_i
    end

    it 'should set the run_at date to about 4096 seconds from now' do
      failed_job = Navvy::Job.enqueue(Cow, :speak, 'name' => 'Betsy')
      failed_job.stub!(:times_failed).and_return 8
      job = failed_job.retry
      job.run_at.to_i.should == (Time.now + 4096).to_i
    end

    it 'should set the parent_id to the master job id' do
      failed_job = Navvy::Job.enqueue(Cow, :speak, 'name' => 'Betsy')
      failed_child = failed_job.retry
      failed_child.retry.parent_id.should == failed_job.id
    end
  end

  describe '#times_failed' do
    before(:each) do
      Navvy::Job.delete_all
      @failed_job = Navvy::Job.create(
        :failed_at => Time.now
      )
    end

    it 'should return 1' do
      @failed_job.times_failed.should == 1
    end

    it 'should return 3 when having 2 failed children' do
      2.times do
        Navvy::Job.create(
          :failed_at => Time.now,
          :parent_id => @failed_job.id
        )
      end

      @failed_job.times_failed.should == 3
    end

    it 'should return 2 when having 1 failed and one pending child' do
      Navvy::Job.create(
        :failed_at => Time.now,
        :parent_id => @failed_job.id
      )

      Navvy::Job.create(
        :parent_id => @failed_job.id
      )

      Navvy::Job.create(
        :parent_id => @failed_job.id
      )

      @failed_job.times_failed.should == 2
    end

    it 'should return 2 when having failed and having a failed parent' do
      failed_child =  Navvy::Job.create(
        :failed_at => Time.now,
        :parent_id => @failed_job.id
      )
      failed_child.times_failed.should == 2
    end
  end

  describe '#ran?' do
    it 'should return false when failed_at? and completed_at? are false' do
      job = Navvy::Job.create
      job.ran?.should be_false
    end

    it 'should return true when failed_at? or completed_at? is true' do
      [
        Navvy::Job.create(:failed_at => Time.now),
        Navvy::Job.create(:completed_at => Time.now)
      ].each do |job|
        job.ran?.should be_true
      end
    end
  end

  describe '#duration' do
    it 'should return a duration if started_at and completed_at are set' do
      job = Navvy::Job.create(
        :started_at =>    Time.now - 2,
        :completed_at =>  Time.now
      )

      job.duration.should == 2
    end

    it 'should return a duration if started_at and failed_at are set' do
      job = Navvy::Job.create(
        :started_at =>  Time.now - 3,
        :failed_at =>   Time.now
      )

      job.duration.should == 3
    end

    it 'should return 0 if only started_at is set' do
      job = Navvy::Job.create(
        :started_at => Time.now - 4
      )

      job.duration.should == 0
    end
  end

  describe '#args' do
    it 'should return an array of arguments' do
      job = Navvy::Job.enqueue(Cow, :speak, true, false)
      job.args.should be_instance_of Array
      job.args.count.should == 2
    end
  end

  describe '#namespaced' do
    it 'should accept a namespaced class name' do
      job = Navvy::Job.enqueue(Animals::Cow, :speak)
      job.run.should == '"moo"'
    end
  end
end
