module FSEvents
  class Event
    attr_reader :id, :path, :stream
    
    def initialize(id, path, stream)
      @id     = id
      @path   = path
      @stream = stream
    end
    
    def files
      Dir["#{path}/*"]
    end
    
    def modified_files
      case stream.mode
      when :mtime
        files.select { |f|  File.mtime(f) >= stream.last_event }
      when :cache
        cache = stream.dirs[path] || {}
        
        files.select do |f|
          cached = cache[f]
          
          cached.nil? or
          
          File.mtime(f) != cached.mtime or
          File.size(f)  != cached.size
        end
      end
    end
  end
end
