require 'spec_helper'

describe Navvy::Logger do
  describe '#colorized_info' do
    describe 'when logging to STDOUT' do
      it 'should use the provided colors' do
        logger = Navvy::Logger.new
        logger.should_not_receive(:info).with('colors!')
        logger.should_receive(:info).with("\e[32mcolors!\e[0m")
        logger.colorized_info 'colors!', 32
      end
    end

    describe 'when logging to a file' do
      it 'should not use the provided colors' do
        logger = Navvy::Logger.new('/dev/null')
        logger.should_receive(:info).with('colors!')
        logger.should_not_receive(:info).with("\e[32mcolors!\e[0m")
        logger.colorized_info 'colors!', 32
      end
    end
  end
end
