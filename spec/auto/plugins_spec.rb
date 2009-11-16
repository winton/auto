require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module Auto
  describe Auto::Plugins do
    
    before(:all) do
      Plugins.add_repository @fixtures = "#{SPEC}/plugins"
      @libraries = Plugins.libraries
      @modules = Plugins.modules
      @tasks = Plugins.tasks
      # debug @libraries
      # debug @modules
      # debug @tasks
    end
    
    it "should provide an array of plugin library files" do
      @libraries.should == [
        "#{@fixtures}/auto-plugin-0.0.0/lib/auto/plugin.rb",
        "#{@fixtures}/auto-plugin2/lib/auto/plugin2.rb"
      ]
    end
    
    it "should provide an array of module strings" do
      @modules.should == [ 'Plugin', 'Plugin2' ]
    end
    
    it "should provide a hash of plugin task information" do
      @tasks.should == [
        {
          :path => "#{@fixtures}/auto-plugin-0.0.0/.auto/plugin/task.rb",
          :name => "plugin:task"
        },
        {
          :path => "#{@fixtures}/auto-plugin2/.auto/plugin2/task.rb",
          :name => "plugin2:task"
        },
        {
          :path => "#{@fixtures}/auto-plugin2/.auto/plugin2/task2.rb",
          :name => "plugin2:task2"
        }
      ]
    end
  end
end