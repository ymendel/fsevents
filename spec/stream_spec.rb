require File.dirname(__FILE__) + '/spec_helper.rb'

describe FSEvents::Stream do
  describe 'when initialized' do
    before :each do
      @path = '/tmp'
      OSX.stubs(:FSEventStreamCreate)
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
      OSX.expects(:FSEventStreamCreate)
      FSEvents::Stream.new(@path)
    end
    
    describe 'when creating the stream' do
      it 'should pass the allocator'
      it 'should pass the callback'
      it 'should pass the context'
      it 'should pass the path'
      it 'should pass the since'
      it 'should pass the latency'
      it 'should pass the flags'
      
      it 'should default the allocator to KCFAllocatorDefault'  # OSX::KCFAllocatorDefault
      # it 'should default the callback' # files changed
      it 'should default the context to nil'
      # it 'should default the path' # Dir.pwd
      it 'should default the since to KFSEventStreamEventIdSinceNow'  # OSX::KFSEventStreamEventIdSinceNow 
      it 'should default the latency to 1.0'
      it 'should default the flags to 0'
      
      it 'should store the stream'
    end
  end
end
