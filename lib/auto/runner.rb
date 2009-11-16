module Auto
  class Runner
    
    def initialize(path_or_task=nil, &block)
      self.class.require!
      run(path_or_task, &block)
    end
    
    def run(path_or_task=nil, &block)
      self.instance_eval(&block) if block
      if path_or_task
        if File.exists?(path_or_task)
          @path = path_or_task
        elsif task = Plugins.tasks(path_or_task)
          @path = task[:path]
        end
        self.instance_eval(File.read(@path), @path) if @path
      end
      self
    end
    
    class <<self

      def require!(plugin=nil)
        require_all! and return unless plugin
        if plugin.library
          require plugin.library
        end
        begin
          include eval(plugin.module)
        rescue
        end
      end
      
      def require_all!
        Plugins.plugins.each do |plugin|
          require! plugin
        end
      end
    end
  end
end