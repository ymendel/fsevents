module FSEvents
  class Stream
    def initialize(path, options = {})
      stream_create_args  = []
      stream_create_args.push *options.values_at(:allocator, :callback, :context)
      stream_create_args.push [path]
      stream_create_args.push *options.values_at(:since, :latency, :flags)
      OSX.FSEventStreamCreate(*stream_create_args)
    end
  end
end
