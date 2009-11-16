module Auto
  class Plugins
    
    @@plugin_paths = []
    @@plugins = nil
    
    cattr_accessor :directories
    
    class <<self
      
      # Add a plugin directory
      def add(path)
        @@plugin_paths << path
        @@plugins = nil
      end
      
      # Add a repository of plugins
      def add_repository(path)
        Dir["#{path}/auto-*"].each do |plugin|
          Plugins.add plugin
        end
      end
      
      # Returns an array of Plugin instances.
      def plugins
        return @@plugins if @@plugins
        unless $testing
          specs = Gem.source_index.latest_specs.select do |spec|
            spec.name =~ /^auto-.+/
          end
          @@plugin_paths += specs.collect &:full_gem_path
          # Treat the home directory like a plugin for the .auto directory
          @@plugin_paths << File.expand_path('~')
          @@plugin_paths.compact!
        end
        @@plugins = Dir[*@@plugin_paths].collect do |d|
          Plugin.new(d)
        end
        @@plugins || []
      end
      
      # Returns an array of library file paths.
      def libraries
        collector &:library
      end
      
      # Returns an array of modules.
      def modules
        collector &:module
      end
      
      # Returns a sorted array of hashes that describe tasks.
      # Returns a specific task with an optional task parameter (string, 'task:name').
      def tasks(task=nil)
        if task
          tasks.select { |t| t[:name] == task.downcase }.first
        else
          collector(&:tasks).flatten.sort do |a, b|
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
        
        if name.include?('auto')
          @name = name[name.index('auto') + 1]
        else
          @name = nil
        end
        
        # ~/.auto/auto-plugin/lib/plugin.rb
        @library = "#{directory}/lib/auto/#{@name}.rb"
        @library = nil unless File.exists?(@library)
        
        # Auto::Plugin
        if @library
          @module = File.basename(@library, '.rb').camelize
        else
          @module = nil
        end
        
        # ~/.auto/auto-plugin/.auto/task.rb
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