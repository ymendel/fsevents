require File.dirname(__FILE__) + '/spec_helper.rb'

describe FSEvents::Event do
  before :each do
    @id     = stub('id')
    @path   = '.'
    @stream = stub('stream')
    
    @event = FSEvents::Event.new(@id, @path, @stream)
  end
  
  describe 'when initialized' do    
    it 'should accept an id, path, and stream' do
      lambda { FSEvents::Event.new(@id, @path, @stream) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a stream' do
      lambda { FSEvents::Event.new(@id, @path) }.should raise_error(ArgumentError)
    end
    
    it 'should require a path' do
      lambda { FSEvents::Event.new(@id) }.should raise_error(ArgumentError)
    end
    
    it 'should require an id' do
      lambda { FSEvents::Event.new }.should raise_error(ArgumentError)
    end
    
    it 'should store the id' do
      FSEvents::Event.new(@id, @path, @stream).id.should == @id
    end
    
    it 'should store the path' do
      FSEvents::Event.new(@id, @path, @stream).path.should == @path
    end
    
    it 'should store the stream' do
      FSEvents::Event.new(@id, @path, @stream).stream.should == @stream
    end
  end
  
  it 'should list files' do
    @event.should respond_to(:files)
  end
  
  describe 'listing files' do
    it 'should get files from the path' do
      @event.files.sort.should == Dir["#{@path}/*"].sort
    end
  end  
end
