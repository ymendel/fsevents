module FSEvents
  class Stream
    def initialize(path, options = {})
      OSX.FSEventStreamCreate(*options.values_at(:allocator, :callback, :context, :path, :since, :latency, :flags))
    end
  end
end
