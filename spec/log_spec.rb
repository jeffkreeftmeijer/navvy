require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class LoggerNotFound < StandardError; end

describe Navvy::Log do
  describe '.info' do
    describe 'when using the rails default logger' do
      before do
        Navvy::Log.logger = :rails
      end
      
      it 'should raise an error when the logger can not be found' do
        lambda { Navvy::Log.info('123') }.should raise_error
      end
      
      it 'should pass the log to RAILS_DEFAULT_LOGGER' do
        class RailsLogger
          def self.info(text);end
        end

        RAILS_DEFAULT_LOGGER = RailsLogger
        
        RAILS_DEFAULT_LOGGER.should_receive(:info).with('123')
        Navvy::Log.info('123')
      end
    end

    describe 'when using justlogging' do
      before do
        Navvy::Log.logger = :justlogging
      end
      
      it 'should raise an error when the logger can not be found' do
        lambda { Navvy::Log.info('123') }.should raise_error
      end
      
      it 'should pass the log to justlogging' do
        class Justlogging
          def self.log(text);end
        end
        
        Justlogging.should_receive(:log).with('123')
        Navvy::Log.info('123')
      end
    end

    describe 'when using both the rails default logger and justlogging' do
      before do
        Navvy::Log.logger = [:rails, :justlogging]
      end

      it 'should pass the log to justlogging' do
        RAILS_DEFAULT_LOGGER.should_receive(:info).with('123')
        Justlogging.should_receive(:log).with('123')
        Navvy::Log.info('123')
      end
    end
    
    describe 'when not using any logger' do
      before do
        Navvy::Log.logger = nil
      end
      
      it 'should not log' do
        RAILS_DEFAULT_LOGGER.should_not_receive(:info)
        Justlogging.should_not_receive(:log)
        Navvy::Log.info('123')
      end
    end
  end
end
