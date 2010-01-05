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
    end
  end
end

class Cow
  def self.speak
    'moo'
  end
end
