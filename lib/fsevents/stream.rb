module FSEvents
  class Stream
    attr_reader :stream
    attr_reader :allocator, :context, :paths, :since, :latency, :flags, :callback
    
    class StreamError < StandardError; end
    
    def initialize(*paths, &callback)
      @callback = callback
      
      options = {}
      options = paths.pop if paths.last.is_a?(Hash)
      
      paths = Dir.pwd if paths.empty?
      
      @allocator = options[:allocator] || OSX::KCFAllocatorDefault
      callback  = options[:callback]
      @context   = options[:context]   || nil
      @paths     = [paths].flatten
      @since     = options[:since]     || OSX::KFSEventStreamEventIdSinceNow
      @latency   = options[:latency]   || 1.0
      @flags     = options[:flags  ]   || 0
      
      paths = @paths
      @stream = OSX.FSEventStreamCreate(allocator, callback, context, paths, since, latency, flags)
      raise StreamError, 'Unable to create FSEvents stream.' unless @stream
    end
    
    def stream_callback
      lambda do |stream, context, event_count, paths, event_flags, event_IDs|
        paths.regard_as('*')
        
        events = []
        event_count.times { |i|  events << paths[i] }
        
        callback.call(events)
      end
    end
    
    def schedule
      OSX.FSEventStreamScheduleWithRunLoop(stream, OSX.CFRunLoopGetCurrent, OSX::KCFRunLoopDefaultMode)
    end
    
    def start
      OSX.FSEventStreamStart(stream) or raise StreamError, 'Could not start stream'
    end
    
    def startup
      schedule
      start
    end
    
    def stop
      OSX.FSEventStreamStop(stream)
    end
    
    def invalidate
      OSX.FSEventStreamInvalidate(stream)
    end
    
    def release
      OSX.FSEventStreamRelease(stream)
      @stream = nil
    end
    
    def shutdown
      stop
      invalidate
      release
    end
  end
end
