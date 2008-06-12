module FSEvents
  class Stream
    attr_reader :stream
    
    class StreamError < StandardError; end
    
    def initialize(path, options = {})
      allocator = options[:allocator] || OSX::KCFAllocatorDefault
      callback  = options[:callback]
      context   = options[:context]   || nil
      path      = [path]
      since     = options[:since]     || OSX::KFSEventStreamEventIdSinceNow
      latency   = options[:latency]   || 1.0
      flags     = options[:flags  ]   || 0
      
      @stream = OSX.FSEventStreamCreate(allocator, callback, context, path, since, latency, flags)
      raise StreamError, 'Unable to create FSEvents stream.' unless @stream
    end
    
    def schedule
      OSX.FSEventStreamScheduleWithRunLoop(stream, OSX.CFRunLoopGetCurrent, OSX::KCFRunLoopDefaultMode)
    end
    
    def start
      OSX.FSEventStreamStart(stream)
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
  end
end
