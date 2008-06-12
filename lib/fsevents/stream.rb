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
  end
end
