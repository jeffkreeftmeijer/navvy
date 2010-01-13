require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Navvy::Log do
  describe '.info' do 
    describe 'when using the rails default logger' do         
      it 'should pass the log to RAILS_DEFAULT_LOGGER' do
        RAILS_DEFAULT_LOGGER.should_receive(:info).with('123')
        Navvy::Log.info('123')
      end
    end
    
    describe 'when using justlogging' do
      before do
        Navvy::Log.logger = :justlogging
      end
      
      it 'should pass the log to justlogging' do
        Justlogging.should_receive(:log).with('123')
        Navvy::Log.info('123')
      end
    end
    
    describe 'when using the rails default logger and justlogging' do
      before do
        Navvy::Log.logger = [:rails, :justlogging]
      end
      
      it 'should pass the log to justlogging' do
        RAILS_DEFAULT_LOGGER.should_receive(:info).with('123')
        Justlogging.should_receive(:log).with('123')
        Navvy::Log.info('123')
      end
    end
  end
end
