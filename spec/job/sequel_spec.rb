require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Navvy::Job' do
  before do
    require File.expand_path(File.dirname(__FILE__) + '/../setup/sequel')
  end

  describe '.enqueue' do
    before(:each) do
      Navvy::Job.delete
    end

    it 'should enqueue a job' do
      Navvy::Job.enqueue(Cow, :speak)
      Navvy::Job.count.should == 1
    end

    it 'should set the object and the method' do
      Navvy::Job.enqueue(Cow, :speak)
      job = Navvy::Job.first
      job.object.should == 'Cow'
      job.method_name.should == 'speak'
    end

    it 'should turn the method into a symbol' do
      Navvy::Job.enqueue(Cow, 'speak')
      job = Navvy::Job.first
      job.method_name.should == 'speak'
    end

    it 'should set the arguments' do
      Navvy::Job.enqueue(Cow, :speak, true, false)
      job = Navvy::Job.first
      YAML.load(job.arguments).should == [true, false]
    end

    it 'should set the created_at date' do
      Navvy::Job.enqueue(Cow, :speak, true, false)
      job = Navvy::Job.first
      job.created_at.should be_instance_of Time
      job.created_at.should <= Time.now
    end

    it 'should set the run_at date' do
      Navvy::Job.enqueue(Cow, :speak, true, false)
      job = Navvy::Job.first
      job.run_at.should be_instance_of Time
      job.run_at.should <= Time.now
    end
    
    it 'should return the enqueued job' do
      Navvy::Job.enqueue(Cow, :speak, true, false).
        should be_instance_of Navvy::Job
    end
  end

  describe '.next' do
    before(:each) do
      Navvy::Job.delete
      Navvy::Job.insert(
        :object =>      'Cow',
        :method_name =>      :last.to_s,
        :created_at =>  Time.now + (60*60*24),
        :run_at =>        Time.now
      )
      Navvy::Job.insert(
        :object =>        'Cow',
        :method_name =>        :break.to_s,
        :completed_at =>  Time.now,
        :run_at =>        Time.now
      )
      Navvy::Job.insert(
        :object =>    'Cow',
        :method_name =>    :break.to_s,
        :failed_at => Time.now,
        :run_at =>    Time.now
      )
      Navvy::Job.insert(
        :object =>  'Cow',
        :method_name =>  :tomorrow.to_s,
        :run_at =>  Time.now + (60*60*24)
      )
      120.times do
        Navvy::Job.enqueue(Cow, :speak)
      end
    end
  
    it 'should find the next 10 available jobs' do
      jobs = Navvy::Job.next
      jobs.count.should == 100
      jobs.each do |job|
        job.should be_instance_of Navvy::Job
        job.method_name.should == 'speak'
      end
    end
  
    it 'should find the next 2 available jobs' do
      Navvy::Job.next(2).count.should == 2
    end
  
    it 'should find the next 4 available jobs' do
      Navvy::Job.limit = 4
      Navvy::Job.next.count.should == 4
    end
  end
  
  describe '.cleanup' do
    before(:each) do
      Navvy::Job.delete
      Navvy::Job.create(
        :object =>      'Cow',
        :method_name =>      :speak.to_s,
        :completed_at => Time.now - (60*60*24*2)
      )
      Navvy::Job.create(
        :object =>        'Cow',
        :method_name =>        :speak.to_s,
        :completed_at =>  Time.now
      )
      Navvy::Job.create(
        :object =>        'Cow',
        :method_name =>        :speak.to_s
      )
    end
  
    it 'should delete all complete jobs when "keep" is false' do
      Navvy::Job.cleanup
      Navvy::Job.count.should == 1
    end
  
    it 'should not delete any complete jobs when "keep" is true' do
      Navvy::Job.keep = true
      Navvy::Job.cleanup
      Navvy::Job.count.should == 3
    end
  
    it 'should delete all complete jobs where "keep" has passed' do
      Navvy::Job.keep = (60*60*24)
      Navvy::Job.cleanup
      Navvy::Job.count.should == 2
    end
  end
  
  describe '#run' do
    
    it 'should pass the arguments' do
      Navvy::Job.delete
      job = Navvy::Job.enqueue(Cow, :name, 'Betsy')
      Cow.should_receive(:name).with('Betsy')
      job.run
    end
    
    describe 'when everything goes well' do
      before(:each) do
        Navvy::Job.delete
        Navvy::Job.enqueue(Cow, :speak)
        Navvy::Job.keep = false
      end
  
      it 'should run the job and delete it' do
        jobs = Navvy::Job.next
        jobs.first.run.should == 'moo'
        Navvy::Job.count.should == 0
      end
  
      describe 'when Navvy::Job.keep is set' do
        it 'should mark the job as complete when keep is true' do
          Navvy::Job.keep = true
          jobs = Navvy::Job.next
          jobs.first.run
          Navvy::Job.count.should == 1
          jobs.first.started_at.should be_instance_of Time
          jobs.first.completed_at.should be_instance_of Time
        end
  
        it 'should mark the job as complete when keep has not passed yer' do
          Navvy::Job.keep = (60*60*24)
          jobs = Navvy::Job.next
          jobs.first.run
          Navvy::Job.count.should == 1
          jobs.first.started_at.should be_instance_of Time
          jobs.first.completed_at.should be_instance_of Time
        end
  
        it 'should delete the job when the "keep" flag has passed' do
          Navvy::Job.keep = -(60*60*24)
          jobs = Navvy::Job.next
          jobs.first.run
          Navvy::Job.count.should == 0
        end
      end
    end
  
    describe 'when a job fails' do
      before(:each) do
        Navvy::Job.delete
        Navvy::Job.enqueue(Cow, :broken)
      end
  
      it 'should store the exception and current time' do
        jobs = Navvy::Job.next
        jobs.first.run
        Navvy::Job.count.should == 1
        jobs.first.exception.should == 'this method is broken'
        jobs.first.started_at.should be_instance_of Time
        jobs.first.failed_at.should be_instance_of Time
      end
    end
  end
  
  describe '#completed' do
    before(:each) do
      Navvy::Job.delete
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
      Navvy::Job.delete
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
        :started_at =>    (Time.now - 2),
        :completed_at =>  Time.now
      )
      job.duration.should >= 2
    end
    
    it 'should return a duration if started_at and failed_at are set' do
      job = Navvy::Job.create(
        :started_at =>  (Time.now - 3),
        :failed_at =>   Time.now
      )
  
      job.duration.should >= 2
    end
  
    it 'should return 0 if only started_at is set' do
      job = Navvy::Job.create(
        :started_at => (Time.now - 4)
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
end
