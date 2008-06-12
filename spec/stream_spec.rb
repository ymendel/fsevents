require File.dirname(__FILE__) + '/spec_helper.rb'

describe FSEvents::Stream do
  describe 'when initialized' do
    before :each do
      @stream = stub('stream')
      @path = '/tmp'
      OSX.stubs(:FSEventStreamCreate).returns(@stream)
    end
    
    it 'should accept a path' do
      lambda { FSEvents::Stream.new(@path) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a path' do
      lambda { FSEvents::Stream.new }.should raise_error(ArgumentError)
    end
    
    it 'should accept a hash of options' do
      lambda { FSEvents::Stream.new(@path, { :flags => 27 }) }.should_not raise_error(ArgumentError)
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
      
      # it 'should default the path' # Dir.pwd
      
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
end

describe FSEvents::Stream::StreamError do
  it 'should be a type of StandardError' do
    FSEvents::Stream::StreamError.should < StandardError
  end
end
