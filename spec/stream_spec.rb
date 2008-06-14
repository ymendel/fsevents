require File.dirname(__FILE__) + '/spec_helper.rb'

describe FSEvents::Stream do
  before :each do
    @path = "/tmp"
    stream = stub('stream')
    OSX.stubs(:FSEventStreamCreate).returns(stream)
    
    @stream = FSEvents::Stream.new(@path)
  end
  
  describe 'when initialized' do
    before :each do
      @stream = stub('stream')
      @path = '/tmp'
      OSX.stubs(:FSEventStreamCreate).returns(@stream)
    end
    
    it 'should accept a path and callback block' do
      lambda { FSEvents::Stream.new(@path) {} }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require a path' do
      lambda { FSEvents::Stream.new() {} }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require a callback block' do
      lambda { FSEvents::Stream.new(@path) }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept a hash of options' do
      lambda { FSEvents::Stream.new(@path, :flags => 27 ) }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept an array of paths' do
      lambda { FSEvents::Stream.new([@path, '/other/path']) }.should_not raise_error
    end
    
    it 'should accept an array of paths with options' do
      lambda { FSEvents::Stream.new([@path, '/other/path'], :flags => 27) }.should_not raise_error
    end
    
    it 'should accept multiple paths' do
      lambda { FSEvents::Stream.new(@path, '/other/path') }.should_not raise_error
    end
    
    it 'should accept multiple paths with options' do
      lambda { FSEvents::Stream.new(@path, '/other/path', :flags => 27) }.should_not raise_error
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
        @other_path = '/other/path'
      end
      
      it 'should store the allocator' do
        FSEvents::Stream.new(@path, @options).allocator.should == @options[:allocator]
      end
      
      it 'should default the allocator to KCFAllocatorDefault' do
        @options.delete(:allocator)
        FSEvents::Stream.new(@path, @options).allocator.should == OSX::KCFAllocatorDefault
      end
      
      it 'should store the context' do
        FSEvents::Stream.new(@path, @options).context.should == @options[:context]
      end
      
      it 'should default the context to nil' do
        @options.delete(:context)
        FSEvents::Stream.new(@path, @options).context.should == nil
      end
      
      it 'should store the path as an array' do
        FSEvents::Stream.new(@path, @options).paths.should == [@path]
      end
      
      it 'should store an array of paths as-is' do
        FSEvents::Stream.new([@path, @other_path], @options).paths.should == [@path, @other_path]
      end
      
      it 'should store multiple paths as an array' do
        FSEvents::Stream.new(@path, @other_path, @options).paths.should == [@path, @other_path]
      end
      
      it 'should default the path to the present working directory' do
        FSEvents::Stream.new(@options).paths.should == [Dir.pwd]
      end
      
      it "should store 'since' (event ID)" do
        FSEvents::Stream.new(@path, @options).since.should == @options[:since]
      end
      
      it "should default 'since' to KFSEventStreamEventIdSinceNow" do
        @options.delete(:since)
        FSEvents::Stream.new(@path, @options).since.should == OSX::KFSEventStreamEventIdSinceNow
      end
      
      it 'should store the latency' do
        FSEvents::Stream.new(@path, @options).latency.should == @options[:latency]
      end
      
      it 'should default the latency to 1.0' do
        @options.delete(:latency)
        FSEvents::Stream.new(@path, @options).latency.should == 1.0
      end
      
      it 'should store the flags' do
        FSEvents::Stream.new(@path, @options).flags.should == @options[:flags]
      end
      
      it 'should default the flags to 0' do
        @options.delete(:flags)
        FSEvents::Stream.new(@path, @options).flags.should == 0
      end
    end
    
    it 'should create a new stream' do
      OSX.expects(:FSEventStreamCreate).returns(@stream)
      FSEvents::Stream.new(@path)
    end
    
    describe 'when creating the stream' do
      before :each do
        @options = {}
        [:allocator, :callback, :context, :since, :latency, :flags].each do |opt|
          val = stub(opt.to_s)
          
          instance_variable_set("@#{opt}", val)
          @options[opt] = val
        end
        
        @arg_placeholders = Array.new(7) { anything }
      end
      
      it 'should pass the allocator' do
        args = @arg_placeholders
        args[0] = @allocator
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should pass the callback' do
        args = @arg_placeholders
        args[1] = @callback
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should pass the context' do
        args = @arg_placeholders
        args[2] = @context
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should pass the path as an array' do
        args = @arg_placeholders
        args[3] = [@path]
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should pass the paths as-is if given an array of paths' do
        other_path = '/other/path'
        args = @arg_placeholders
        args[3] = [@path, other_path]
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new([@path, other_path], @options)
      end
      
      it 'should make an array of the paths if given multiple paths' do
        other_path = '/other/path'
        args = @arg_placeholders
        args[3] = [@path, other_path]
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, other_path, @options)
      end
      
      it 'should pass the since (event ID)' do
        args = @arg_placeholders
        args[4] = @since
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should pass the latency' do
        args = @arg_placeholders
        args[5] = @latency
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should pass the flags' do
        args = @arg_placeholders
        args[6] = @flags
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should default the allocator to KCFAllocatorDefault' do
        @options.delete(:allocator)
        args = @arg_placeholders
        args[0] = OSX::KCFAllocatorDefault
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      # it 'should default the callback' # files changed
      
      it 'should default the context to nil' do
        @options.delete(:context)
        args = @arg_placeholders
        args[2] = nil
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should default the path to the present working directory' do
        args = @arg_placeholders
        args[3] = [Dir.pwd]
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@options)
      end
      
      it 'should default the since to KFSEventStreamEventIdSinceNow' do
        @options.delete(:since)
        args = @arg_placeholders
        args[4] = OSX::KFSEventStreamEventIdSinceNow
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should default the latency to 1.0' do
        @options.delete(:latency)
        args = @arg_placeholders
        args[5] = 1.0
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should default the flags to 0' do
        @options.delete(:flags)
        args = @arg_placeholders
        args[6] = 0
        OSX.expects(:FSEventStreamCreate).with(*args).returns(@stream)
        FSEvents::Stream.new(@path, @options)
      end
      
      it 'should store the stream' do
        FSEvents::Stream.new(@path, @options).stream.should == @stream
      end
      
      it 'should raise a StreamError exception if the stream could not be created' do
        OSX.stubs(:FSEventStreamCreate).returns(nil)
        lambda { FSEvents::Stream.new(@path, @options) }.should raise_error(FSEvents::Stream::StreamError)
      end
      
      it 'should not raise a StreamError exception if the stream could be created' do
        lambda { FSEvents::Stream.new(@path, @options) }.should_not raise_error(FSEvents::Stream::StreamError)
      end
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
end

describe FSEvents::Stream::StreamError do
  it 'should be a type of StandardError' do
    FSEvents::Stream::StreamError.should < StandardError
  end
end
