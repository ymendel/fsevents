require 'fsevents/event'

module FSEvents
  class Stream
    attr_reader :stream, :mode, :last_event, :dirs
    attr_reader :allocator, :context, :paths, :since, :latency, :flags, :callback
    
    class StreamError < StandardError; end
    
    MODES = [:mtime, :cache]
    
    def initialize(*paths, &callback)
      raise ArgumentError, 'A callback block is required' if callback.nil?
      @callback = callback
      
      options = {}
      options = paths.pop if paths.last.is_a?(Hash)
      
      @mode = options[:mode] || :mtime
      raise ArgumentError, "Mode '#{mode}' unknown" unless MODES.include?(@mode)
      @dirs = {}
      
      paths = Dir.pwd if paths.empty?
      paths = [paths].flatten.collect { |path|  path.sub(%r%/$%, '') }
      
      @allocator = options[:allocator] || OSX::KCFAllocatorDefault
      @context   = options[:context]   || nil
      @paths     = paths
      @since     = options[:since]     || OSX::KFSEventStreamEventIdSinceNow
      @latency   = options[:latency]   || 1.0
      @flags     = options[:flags]     || 0
    end
    
    def create
      @stream = OSX.FSEventStreamCreate(allocator, stream_callback, context, paths, since, latency, flags)
      raise StreamError, 'Unable to create FSEvents stream.' unless @stream
    end
    
    def stream_callback
      lambda do |stream, context, event_count, paths, event_flags, event_IDs|
        paths.regard_as('*')
        
        events = []
        events.extend(EventArray)
        event_count.times { |i|  events << Event.new(event_IDs[i], paths[i], self) }
        
        callback.call(events)
        
        update_last_event
      end
    end
    
    def schedule
      OSX.FSEventStreamScheduleWithRunLoop(stream, OSX.CFRunLoopGetCurrent, OSX::KCFRunLoopDefaultMode)
    end
    
    def start
      OSX.FSEventStreamStart(stream) or raise StreamError, 'Could not start stream'
      update_last_event
    end
    
    def update_last_event
      case mode
      when :mtime
        @last_event = Time.now
      when :cache
        cache_paths = paths.dup
        cache_paths.each do |path|
          dirs[path] = {}
          Dir["#{path}/*"].each do |file|
            stat = File::Stat.new(file)
            dirs[path][file] = stat
            cache_paths.push(file) if stat.directory?
          end
        end
      end
    end
    
    def startup
      schedule
      start
    end
    
    class << self
      def create(*args, &block)
        stream = new(*args, &block)
        stream.create
        stream
      end
      
      def watch(*args, &block)
        stream = create(*args, &block)
        stream.startup
        stream
      end
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
    
    def run
      OSX.CFRunLoopRun
    end
  end
end
