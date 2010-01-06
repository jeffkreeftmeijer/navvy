require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Navvy::Job do
  describe 'using MongoMapper' do
    before do
      MongoMapper.database = 'navvy_test'
    end

    describe ' .enqueue' do
      before(:each) do
        Navvy::Job.delete_all
      end

      it 'should enqueue a job' do
        Navvy::Job.enqueue(Cow, :speak)
        Navvy::Job.count.should == 1
      end

      it 'should set the object and the method' do
        Navvy::Job.enqueue(Cow, :speak)
        job = Navvy::Job.first
        job.object.should == 'Cow'
        job.method.should == :speak
      end

      it 'should turn the method into a symbol' do
        Navvy::Job.enqueue(Cow, 'speak')
        job = Navvy::Job.first
        job.method.should == :speak
      end

      it 'should set the arguments' do
        Navvy::Job.enqueue(Cow, :speak, true, false)
        job = Navvy::Job.first
        job.arguments.should == [true, false]
      end
      
      it 'should set the run_at date' do
        Navvy::Job.enqueue(Cow, :speak, true, false)
        job = Navvy::Job.first
        job.run_at.should be_instance_of Time
        job.run_at.should <= Time.now
      end
    end

    describe ' .next' do
      before(:each) do
        Navvy::Job.delete_all
        Navvy::Job.create(
          :object =>    'Cow',
          :method =>    :break,
          :failed_at => Time.now
        )
        Navvy::Job.create(
          :object =>  'Cow',
          :method =>  :tomorrow,
          :run_at =>  Time.now + 1.day
        )
        Navvy::Job.enqueue(Cow, :speak)
        Navvy::Job.enqueue(Cow, :sleep)
      end

      it 'should find the next available job' do
        job = Navvy::Job.next
        job.should be_instance_of Navvy::Job
        job.method.should == :speak
      end
    end

    describe ' .run' do
      describe 'when everything goes well' do
        before(:each) do
          Navvy::Job.delete_all
          Navvy::Job.enqueue(Cow, :speak)
        end

        it 'should run the job and delete it' do
          job = Navvy::Job.next
          job.run.should == 'moo'
          Navvy::Job.count.should == 0
        end
      end
      
      describe 'when a job fails' do
        before(:each) do
          Navvy::Job.delete_all
          Navvy::Job.enqueue(Cow, :broken)
        end
        
        it 'should store the exception and current time' do
          job = Navvy::Job.next
          job.run
          Navvy::Job.count.should == 1
          job.exception.should == 'this method is broken'
          job.failed_at.should be_instance_of Time
        end
      end
    end
  end
end

class Cow
  def self.speak
    'moo'
  end
  
  def self.broken
    raise 'this method is broken'
  end
end
