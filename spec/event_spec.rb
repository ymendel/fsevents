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
  
  it 'should list modified files' do
    @event.should respond_to(:modified_files)
  end

  describe 'listing modified files' do
    before :each do
      @now = Time.now
      @stream.stubs(:last_event).returns(@now)
      @files = Array.new(5) do |i|
        file = stub("file #{i+1}")
        File.stubs(:mtime).with(file).returns(@now + i - 2)
        file
      end
      @event.stubs(:files).returns(@files)
    end

    it 'should get the file list' do
      @event.expects(:files).returns(@files)
      @event.modified_files
    end

    it 'should get the last event time from the stream' do
      @stream.expects(:last_event).returns(@now)
      @event.modified_files
    end

    it 'should return files modified after the last event time' do
      expected_files = @files.values_at(3, 4)
      modified_files = @event.modified_files

      expected_files.each do |file|
        modified_files.should include(file)
      end
    end

    it 'should return files modified at the last event time' do
      expected_files = @files.values_at(2)
      modified_files = @event.modified_files

      expected_files.each do |file|
        modified_files.should include(file)
      end
    end

    it 'should not return files not modified after the last event time' do
      unexpected_files = @files.values_at(0, 1)
      modified_files = @event.modified_files

      unexpected_files.each do |file|
        modified_files.should_not include(file)
      end
    end
  end
end
