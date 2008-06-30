require File.dirname(__FILE__) + '/spec_helper.rb'

describe FSEvents::Stream do
  before :each do
    @path = '/tmp'
    @stream = FSEvents::Stream.new(@path) {}
  end
  
  describe 'when initialized' do
    it 'should accept a path and callback block' do
      lambda { FSEvents::Stream.new(@path) {} }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require a path' do
      lambda { FSEvents::Stream.new() {} }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a callback block' do
      lambda { FSEvents::Stream.new(@path) }.should raise_error(ArgumentError)
    end
    
    it 'should accept a hash of options' do
      lambda { FSEvents::Stream.new(@path, :flags => 27 ) {} }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept an array of paths' do
      lambda { FSEvents::Stream.new([@path, '/other/path']) {} }.should_not raise_error
    end
    
    it 'should accept an array of paths with options' do
      lambda { FSEvents::Stream.new([@path, '/other/path'], :flags => 27) {} }.should_not raise_error
    end
    
    it 'should accept multiple paths' do
      lambda { FSEvents::Stream.new(@path, '/other/path') {} }.should_not raise_error
    end
    
    it 'should accept multiple paths with options' do
      lambda { FSEvents::Stream.new(@path, '/other/path', :flags => 27) {} }.should_not raise_error
    end
    
    it 'should store the callback block' do
      callback = lambda {}
      FSEvents::Stream.new(@path, &callback).callback.should == callback
    end
    
    describe 'handling options' do
      before :each do
        @options = {}
        [:allocator, :context, :since, :latency, :flags].each do |opt|
          @options[opt] = stub(opt.to_s)
        end
        @options[:mode] = :cache
        @other_path = '/other/path'
      end
      
      it 'should store the allocator' do
        FSEvents::Stream.new(@path, @options) {}.allocator.should == @options[:allocator]
      end
      
      it 'should default the allocator to KCFAllocatorDefault' do
        @options.delete(:allocator)
        FSEvents::Stream.new(@path, @options) {}.allocator.should == OSX::KCFAllocatorDefault
      end
      
      it 'should store the context' do
        FSEvents::Stream.new(@path, @options) {}.context.should == @options[:context]
      end
      
      it 'should default the context to nil' do
        @options.delete(:context)
        FSEvents::Stream.new(@path, @options) {}.context.should == nil
      end
      
      it 'should store the path as an array' do
        FSEvents::Stream.new(@path, @options) {}.paths.should == [@path]
      end
      
      it 'should store an array of paths as-is' do
        FSEvents::Stream.new([@path, @other_path], @options) {}.paths.should == [@path, @other_path]
      end
      
      it 'should store multiple paths as an array' do
        FSEvents::Stream.new(@path, @other_path, @options) {}.paths.should == [@path, @other_path]
      end
      
      it 'should default the path to the present working directory' do
        FSEvents::Stream.new(@options) {}.paths.should == [Dir.pwd]
      end
      
      it 'should strip a trailing slash from the path' do
        FSEvents::Stream.new("#{@path}/", "#{@other_path}/", @options) {}.paths.should == [@path, @other_path]
      end
      
      it "should store 'since' (event ID)" do
        FSEvents::Stream.new(@path, @options) {}.since.should == @options[:since]
      end
      
      it "should default 'since' to KFSEventStreamEventIdSinceNow" do
        @options.delete(:since)
        FSEvents::Stream.new(@path, @options) {}.since.should == OSX::KFSEventStreamEventIdSinceNow
      end
      
      it 'should store the latency' do
        FSEvents::Stream.new(@path, @options) {}.latency.should == @options[:latency]
      end
      
      it 'should default the latency to 1.0' do
        @options.delete(:latency)
        FSEvents::Stream.new(@path, @options) {}.latency.should == 1.0
      end
      
      it 'should store the flags' do
        FSEvents::Stream.new(@path, @options) {}.flags.should == @options[:flags]
      end
      
      it 'should default the flags to 0' do
        @options.delete(:flags)
        FSEvents::Stream.new(@path, @options) {}.flags.should == 0
      end
      
      it 'should store mode' do
        FSEvents::Stream.new(@path, @options) {}.mode.should == @options[:mode]
      end
      
      it 'should default mode to mtime' do
        @options.delete(:mode)
        FSEvents::Stream.new(@path, @options) {}.mode.should == :mtime
      end
      
      it 'should not accept any mode other than mtime or cache' do
        lambda { FSEvents::Stream.new(@path, @options.merge(:mode => :something_else)) {} }.should raise_error(ArgumentError)
      end
    end
  end
  
  it 'should create a stream' do
    @stream.should respond_to(:create)
  end
  
  describe 'when creating the stream' do
    before :each do
      @args = {}
      [:allocator, :context, :paths, :since, :latency, :flags].each do |arg|
        val = stub(arg.to_s)
        
        @stream.stubs(arg).returns(val)
        @args[arg] = val
      end
      
      @arg_placeholders = Array.new(7) { anything }
      
      @stream_val = stub('stream')
      OSX.stubs(:FSEventStreamCreate).returns(@stream_val)
    end
    
    it 'should create an FSEvent stream' do
      OSX.expects(:FSEventStreamCreate).returns(@stream_val)
      @stream.create
    end
    
    it 'should pass the allocator' do
      args = @arg_placeholders
      args[0] = @args[:allocator]
      OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream_val)
      @stream.create
    end
    
    it 'should pass the stream callback' do
      # stream_callback returns a different proc every time it's called
      @stream.stubs(:stream_callback).returns(stub('stream callback'))
      args = @arg_placeholders
      args[1] = @stream.stream_callback
      OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream_val)
      @stream.create
    end
    
    it 'should pass the context' do
      args = @arg_placeholders
      args[2] = @args[:context]
      OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream_val)
      @stream.create
    end
    
    it 'should pass the paths' do
      args = @arg_placeholders
      args[3] = @args[:paths]
      OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream_val)
      @stream.create
    end
    
    it "should pass 'since' (event ID)" do
      args = @arg_placeholders
      args[4] = @args[:since]
      OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream_val)
      @stream.create
    end
    
    it 'should pass the latency' do
      args = @arg_placeholders
      args[5] = @args[:latency]
      OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream_val)
      @stream.create
    end
    
    it 'should pass the flags' do
      args = @arg_placeholders
      args[6] = @args[:flags]
      OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream_val)
      @stream.create
    end
    
    it 'should store the stream' do
      @stream.create
      @stream.stream.should == @stream_val
    end
    
    it 'should raise a StreamError exception if the stream could not be created' do
      OSX.stubs(:FSEventStreamCreate).returns(nil)
      lambda { @stream.create }.should raise_error(FSEvents::Stream::StreamError)
    end
    
    it 'should not raise a StreamError exception if the stream could be created' do
      lambda { @stream.create }.should_not raise_error(FSEvents::Stream::StreamError)
    end
  end
  
  it 'should have a stream callback' do
    @stream.should respond_to(:stream_callback)
  end
  
  describe 'stream callback' do
    it 'should return a proc' do
      @stream.stream_callback.should be_kind_of(Proc)
    end
    
    describe 'proc' do
      before :each do
        @callback_arg_order = [:stream, :context, :event_count, :paths, :event_flags, :event_IDs]
        @args_hash = {}
        [:stream, :context].each do |arg|
          @args_hash[arg] = stub(arg.to_s)
        end
        @args_hash[:event_count] = 0
        [:paths, :event_flags, :event_IDs].each do |arg|
          @args_hash[arg] = []
        end
        @args_hash[:paths].stubs(:regard_as)
        
        @args = @args_hash.values_at(*@callback_arg_order)
        
        @callback = stub('callback', :call => nil)
        @stream.stubs(:callback).returns(@callback)
        
        @proc = @stream.stream_callback
      end
      
      it 'should accept stream, context, event count, paths, event flags, and event IDs' do
        lambda { @proc.call(*@args) }.should_not raise_error(ArgumentError)
      end
      
      it "should regard the paths as '*'" do
        @args_hash[:paths].expects(:regard_as).with('*')
        @proc.call(*@args)
      end
      
      it 'should call the stored callback' do
        @callback.expects(:call)
        @proc.call(*@args)
      end
      
      it 'should collect the paths and IDs, create Event objects, and pass them to the stored callback' do
        event_count = 3
        @args_hash[:event_count] = event_count
        events = []
        event_count.times do |i|
          path = "/some/path/to/dir/number/#{i+1}"
          id = i + 1
          @args_hash[:paths].push path
          @args_hash[:event_IDs].push id
          
          event = stub("event #{path}")
          FSEvents::Event.stubs(:new).with(id, path, @stream).returns(event)
          events.push event
        end
        @args = @args_hash.values_at(*@callback_arg_order)
        @callback.expects(:call).with(events)
        @proc.call(*@args)
      end
      
      it 'should extend the event array' do
        @args = @args_hash.values_at(*@callback_arg_order)
        @callback.expects(:call).with(kind_of(EventArray))
        @proc.call(*@args)
      end
      
      it "should update the stream's last event" do
        @stream.expects(:update_last_event)
        @proc.call(*@args)
      end
    end
  end
  
  it 'should create' do
    FSEvents::Stream.should respond_to(:create)
  end
  
  describe 'when creating' do
    before :each do
      @other_path = '/other/path'
    end
    
    # This is just here for organization and use of the before block.
    # I'd like to ensure that the block is passed to new, but mocha expecation apparently doesn't support that.
    # So instead I stub new for some testing and then have something that actually uses new and sees the callback
    # is the expected block.
    describe do
      before :each do
        @stream.stubs(:create)
        FSEvents::Stream.stubs(:new).returns(@stream)
      end
      
      it 'should accept arguments and a block' do
        lambda { FSEvents::Stream.create(@path, @other_path, :flags => 27) {} }.should_not raise_error(ArgumentError)
      end
      
      it 'should initialize a new stream object' do
        FSEvents::Stream.expects(:new).returns(@stream)
        FSEvents::Stream.create(@path, @other_path, :flags => 27) {}
      end
      
      it 'should pass the arguments to the initialization' do
        FSEvents::Stream.expects(:new).with(@path, @other_path, :flags => 27).returns(@stream)
        FSEvents::Stream.create(@path, @other_path, :flags => 27) {}
      end
      
      it 'should make the resultant stream object create a stream' do
        @stream.expects(:create)
        FSEvents::Stream.create(@path, @other_path, :flags => 27) {}
      end
      
      it 'should return the stream object' do
        FSEvents::Stream.create.should == @stream
      end
    end
    
    it 'should pass the callback block' do
      callback = lambda {}
      FSEvents::Stream.create(@path, @other_path, :flags => 27, &callback).callback.should == callback
    end
  end
  
  it 'should schedule itself' do
    @stream.should respond_to(:schedule)
  end
  
  describe 'when scheduling' do
    before :each do
      OSX.stubs(:FSEventStreamScheduleWithRunLoop)
    end
    
    it 'should schedule the stream' do
      OSX.expects(:FSEventStreamScheduleWithRunLoop)
      @stream.schedule
    end
    
    it 'should pass the stream' do
      OSX.expects(:FSEventStreamScheduleWithRunLoop).with(@stream.stream, anything, anything)
      @stream.schedule
    end
    
    it "should use the 'get current' run loop" do
      OSX.expects(:CFRunLoopGetCurrent)
      @stream.schedule
    end
    
    it "should pass the 'get current' run loop" do
      # CFRunLoopGetCurrent returns a different value every time it's called, so it's like testing Time.now
      get_current_run_loop = OSX.CFRunLoopGetCurrent
      OSX.stubs(:CFRunLoopGetCurrent).returns(get_current_run_loop)
      
      OSX.expects(:FSEventStreamScheduleWithRunLoop).with(anything, get_current_run_loop, anything)
      @stream.schedule
    end
    
    it 'should use the default mode' do
      OSX.expects(:FSEventStreamScheduleWithRunLoop).with(anything, anything, OSX::KCFRunLoopDefaultMode)
      @stream.schedule
    end
  end
  
  it 'should start itself' do
    @stream.should respond_to(:start)
  end
  
  describe 'when starting' do
    before :each do
      OSX.stubs(:FSEventStreamStart).returns(true)
    end
    
    it 'should start the stream' do
      OSX.expects(:FSEventStreamStart).with(@stream.stream).returns(true)
      @stream.start
    end
    
    it 'should raise a StreamError exception if the stream could not be started' do
      OSX.stubs(:FSEventStreamStart).returns(nil)
      lambda { @stream.start }.should raise_error(FSEvents::Stream::StreamError)
    end
    
    it 'should not raise a StreamError exception if the stream could be started' do
      lambda { @stream.start }.should_not raise_error(FSEvents::Stream::StreamError)
    end
    
    it 'should update its last event' do
      @stream.expects(:update_last_event)
      @stream.start
    end
  end
  
  it 'should update its last event' do
    @stream.should respond_to(:update_last_event)
  end
  
  describe 'updating its last event' do
    describe 'when mode is mtime' do
      before :each do
        @stream.stubs(:mode).returns(:mtime)
      end
      
      it 'should store the last event time' do
        now = Time.now
        Time.stubs(:now).returns(now)
        @stream.update_last_event
        @stream.last_event.should == now
      end
    end
    
    describe 'when mode is cache' do
      before :each do
        @stream.stubs(:mode).returns(:cache)
        @files = Array.new(5) { |i|  stub("file #{i+1}") }
        @stats = Array.new(5) { |i|  stub("file #{i+1} stat", :directory? => false) }
        
        @files.zip(@stats).each do |file, stat|
          File::Stat.stubs(:new).with(file).returns(stat)
        end
        
        Dir.stubs(:[]).returns(@files)
      end
      
      it 'should get the contents of its path' do
        Dir.expects(:[]).with("#{@path}/*").returns([])
        @stream.update_last_event
      end
      
      it 'should get stat objects for the path contents' do
        @files.zip(@stats).each do |file, stat|
          File::Stat.expects(:new).with(file).returns(stat)
        end
        @stream.update_last_event
      end
      
      it 'should cache the stat objects' do
        @stream.update_last_event
        
        @files.zip(@stats).each do |file, stat|
          @stream.dirs[@path][file].should == stat
        end
      end
      
      it 'should update already-existent cache entries' do
        file = @files[3]
        val  = @stats[3]
        @stream.dirs[@path] = { file => 'some other val' }
        
        @stream.update_last_event
        @stream.dirs[@path][file].should == val
      end
      
      it 'should remove non-needed cache entries' do
        file = 'some other file'
        @stream.dirs[@path] = { file => 'some val' }
        
        @stream.update_last_event
        @stream.dirs[@path].should_not have_key(file)
      end
      
      it 'should handle multiple paths' do
        other_path = '/other/path'
        paths = [@path, other_path]
        @stream.stubs(:paths).returns(paths)
        
        paths.each do |path|
          Dir.expects(:[]).with("#{path}/*").returns([])
        end
        @stream.update_last_event
      end
      
      it 'should see if there are any subdirectories' do
        @stats.each { |stat|  stat.expects(:directory?) }
        @stream.update_last_event
      end
      
      it 'should cache subdirectories' do
        subdir_path = '/sub/dir/path'
        @files[3].stubs(:to_s).returns(subdir_path)
        @stats[3].stubs(:directory?).returns(true)
        Dir.expects(:[]).with("#{subdir_path}/*").returns([])
        @stream.update_last_event
      end
      
      it 'should not add cached subdirectories to the watched paths' do
        subdir_path = '/sub/dir/path'
        @files[3].stubs(:to_s).returns(subdir_path)
        @stats[3].stubs(:directory?).returns(true)
        Dir.stubs(:[]).with("#{subdir_path}/*").returns([])
        @stream.update_last_event
        @stream.paths.should_not include(@files[3])
      end
    end
  end
  
  it 'should start up' do
    @stream.should respond_to(:startup)
  end
  
  describe 'when starting up' do
    before :each do
      @stream.stubs(:schedule)
      @stream.stubs(:start)
    end
    
    it 'should schedule' do
      @stream.expects(:schedule)
      @stream.startup
    end
    
    it 'should start' do
      @stream.expects(:start)
      @stream.startup
    end
  end
  
  it 'should watch' do
    FSEvents::Stream.should respond_to(:watch)
  end
  
  describe 'when watching' do
    before :each do
      @other_path = '/other/path'
    end
    
    # This is just here for organization and use of the before block.
    # I'd like to ensure that the block is passed to create, but mocha expecation apparently doesn't support that.
    # So instead I stub create for some testing and then have something that actually uses create and sees the callback
    # is the expected block.
    describe do
      before :each do
        @stream.stubs(:startup)
        FSEvents::Stream.stubs(:create).returns(@stream)
      end
      
      it 'should accept arguments and a block' do
        lambda { FSEvents::Stream.watch(@path, @other_path, :flags => 27) {} }.should_not raise_error(ArgumentError)
      end
      
      it 'should create a stream object' do
        FSEvents::Stream.expects(:create).returns(@stream)
        FSEvents::Stream.watch(@path, @other_path, :flags => 27) {}
      end
      
      it 'should pass the arguments to the creation' do
        FSEvents::Stream.expects(:create).with(@path, @other_path, :flags => 27).returns(@stream)
        FSEvents::Stream.watch(@path, @other_path, :flags => 27) {}
      end
      
      it 'should start up the resultant stream object' do
        @stream.expects(:startup)
        FSEvents::Stream.watch(@path, @other_path, :flags => 27) {}
      end
      
      it 'should return the stream object' do
        FSEvents::Stream.watch.should == @stream
      end
    end
    
    it 'should pass the callback block' do
      callback = lambda {}
      FSEvents::Stream.watch(@path, @other_path, :flags => 27, &callback).callback.should == callback
    end
  end
  
  it 'should stop itself' do
    @stream.should respond_to(:stop)
  end
  
  describe 'when stopping' do
    it 'should stop the stream' do
      OSX.expects(:FSEventStreamStop).with(@stream.stream)
      @stream.stop
    end
  end
  
  it 'should invalidate itself' do
    @stream.should respond_to(:invalidate)
  end
  
  describe 'when invalidating' do
    it 'should invalidate the stream' do
      OSX.expects(:FSEventStreamInvalidate).with(@stream.stream)
      @stream.invalidate
    end
  end
  
  it 'should release itself' do
    @stream.should respond_to(:release)
  end
  
  describe 'when releasing' do
    before :each do
      OSX.stubs(:FSEventStreamRelease)
    end
    
    it 'should release the stream' do
      OSX.expects(:FSEventStreamRelease).with(@stream.stream)
      @stream.release
    end
    
    it 'should clear the stream' do
      @stream.release
      @stream.stream.should be_nil
    end
  end
  
  it 'should shut down' do
    @stream.should respond_to(:shutdown)
  end
  
  describe 'when shutting down' do
    before :each do
      @stream.stubs(:stop)
      @stream.stubs(:invalidate)
      @stream.stubs(:release)
    end
    
    it 'should stop' do
      @stream.expects(:stop)
      @stream.shutdown
    end
    
    it 'should invalidate' do
      @stream.expects(:invalidate)
      @stream.shutdown
    end
    
    it 'should release' do
      @stream.expects(:release)
      @stream.shutdown
    end
  end
  
  it 'should run' do
    @stream.should respond_to(:run)
  end
  
  describe 'running' do
    it 'should enter the run loop' do
      OSX.expects(:CFRunLoopRun)
      @stream.run
    end
  end
end

describe FSEvents::Stream::StreamError do
  it 'should be a type of StandardError' do
    FSEvents::Stream::StreamError.should < StandardError
  end
end
