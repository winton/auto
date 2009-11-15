require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module Auto
  describe Auto::Runner do

    before(:all) do
      Plugins.add @fixtures = "#{SPEC}/plugins"
      @runner = Runner.new
    end

    it 'should require plugin library files' do
      $".include?("#{@fixtures}/auto-plugin-0.0.0/lib/plugin.rb").should == true
      $".include?("#{@fixtures}/auto-plugin2/lib/plugin2.rb").should == true
    end

    it 'should include all plugin library modules' do
      @runner.public_methods.include?('plugin').should == true
      @runner.public_methods.include?('plugin2').should == true
    end
  end
end