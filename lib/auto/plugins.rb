require 'rubygems'

module Auto
  class Plugins
    
    @@directories = [
      Gem.dir + "/gems",
      "~/.auto",
      "#{File.dirname(__FILE__)}/../../vendor/plugins"
    ]
    @@plugins = nil
    
    cattr_accessor :directories
    
    class <<self
      
      # Add a directory to the plugin load paths.
      def add(path)
        @@directories = [] if $testing
        @@directories << path
        @@directories.uniq!
        @@plugins = nil
      end
      
      # Returns an array of Plugin instances.
      def plugins
        return @@plugins if @@plugins
        directories = @@directories.collect do |d|
          File.expand_path("#{d}/*auto-*/")
        end
        @@plugins = Dir[*directories].collect do |d|
          Plugin.new(d)
        end
        @@plugins.compact!
        @@plugins
      end
      
      # Returns an array of library file paths.
      def libraries
        collector { |plugin| plugin.library }
      end
      
      # Returns an array of modules.
      def modules
        collector { |plugin| plugin.module }
      end
      
      # Returns a sorted array of hashes that describe tasks.
      # Returns a specific task with an optional task parameter (string, 'task:name').
      def tasks(task=nil)
        if task
          tasks.select { |t| t[:name] == task.downcase }.first
        else
          t = collector { |plugin| plugin.tasks }
          t = t.flatten
          t.sort do |a, b|
            a[:name].gsub(':', '0') <=> b[:name].gsub(':', '0')
          end
        end
      end
      
    private
      
      # A quick way to get an array of @@plugins attributes.
      def collector(&block)
        self.plugins.collect { |plugin| block.call(plugin) }.compact
      end
    end
    
    # Stores a plugin's name, library, and tasks.
    class Plugin

      attr_reader :name
      attr_reader :library
      attr_reader :module
      attr_reader :tasks
      
      # Assigns attributes using a plugin directory path.
      def initialize(directory)
        name = File.basename(directory)
        name = name.split('-')
        
        return nil unless name.include?('auto')
        @name = name[name.index('auto') + 1]
        
        # ~/.auto/auto-plugin/lib/plugin.rb
        @library = "#{directory}/lib/auto/#{@name}.rb"
        @library = nil unless File.exists?(@library)
        
        # Auto::Plugin
        if @library
          @module = File.basename(@library, '.rb').camelize
        else
          @module = nil
        end
        
        # ~/.auto/auto-plugin/auto/task.rb
        @tasks = Dir["#{directory}/.auto/**/*.rb"].sort.collect do |path|
          relative = path.gsub("#{directory}/.auto/", '')
          {
            :name => relative[0..-4].split('/').join(':').downcase,
            :path => path
          }
        end
      end
    end
  end
end