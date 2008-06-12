module FSEvents
  class Stream
    def initialize(path, options = {})
      allocator = options[:allocator] || OSX::KCFAllocatorDefault
      callback  = options[:callback]
      context   = options[:context]   || nil
      path      = [path]
      since     = options[:since]     || OSX::KFSEventStreamEventIdSinceNow
      latency   = options[:latency]   || 1.0
      flags     = options[:flags  ]   || 0
      
      OSX.FSEventStreamCreate(allocator, callback, context, path, since, latency, flags)
    end
  end
end
