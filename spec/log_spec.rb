require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Navvy::Log do
  describe '.info' do    
    it 'should pass the log to RAILS_DEFAULT_LOGGER' do
      RAILS_DEFAULT_LOGGER.should_receive(:info).with('123')
      Navvy::Log.info('123')
    end
  end
end