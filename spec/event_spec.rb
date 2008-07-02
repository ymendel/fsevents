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
    
    it 'should strip a trailing / from the path' do
      FSEvents::Event.new(@id, "#{@path}/", @stream).path.should == @path
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
      @files = Array.new(5) { |i|  stub("file #{i+1}") }
      @event.stubs(:files).returns(@files)
    end
    
    it 'should check the stream mode' do
      @stream.expects(:mode)
      @event.modified_files
    end
    
    describe 'when the stream mode is mtime' do
      before :each do
        @stream.stubs(:mode).returns(:mtime)
      end
      
      before :each do
        @stream.stubs(:last_event).returns(@now)
        @files.each_with_index do |file, i|
          File.stubs(:mtime).with(file).returns(@now + i - 2)
        end
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
    
    describe 'when the stream mode is cache' do
      before :each do
        @stream.stubs(:mode).returns(:cache)
      end
      
      before :each do
        @dir_cache = { @path => {} }
        @files.each_with_index do |file, i|
          size  = 50 * (i + 1)
          mtime = @now + i - 2
          File.stubs(:size).with(file).returns(size)
          File.stubs(:mtime).with(file).returns(mtime)
          stat = stub("file #{i+1} stat", :mtime => mtime, :size => size)
          @dir_cache[@path][file] = stat
        end
        @stream.stubs(:dirs).returns(@dir_cache)
      end
      
      it 'should get the file list' do
        @event.expects(:files).returns(@files)
        @event.modified_files
      end
      
      it 'should get the stream dir cache' do
        @stream.expects(:dirs).returns(@dir_cache)
        @event.modified_files
      end
      
      it 'should get the dir cache for the event path' do
        sub_cache = @dir_cache[@path]
        @dir_cache.expects(:[]).with(@path).returns(sub_cache)
        @event.modified_files
      end
      
      it 'should return files that do not appear in the cache' do
        expected_files = Array.new(2) { |i|  stub("new file #{i+1}") }
        expected_files.each { |file|  @files.push(file) }
        modified_files = @event.modified_files
        
        expected_files.each do |file|
          modified_files.should include(file)
        end
      end
      
      it 'should return files with sizes that differ from the cache' do
        @dir_cache[@path][@files[3]].stubs(:size).returns(3)
        @dir_cache[@path][@files[4]].stubs(:size).returns(101)
        expected_files = @files.values_at(3, 4)
        modified_files = @event.modified_files
        
        expected_files.each do |file|
          modified_files.should include(file)
        end
      end
      
      it 'should return files with mtimes that differ from the cache' do
        @dir_cache[@path][@files[2]].stubs(:mtime).returns(@now - 234)
        expected_files = @files.values_at(2)
        modified_files = @event.modified_files
        
        expected_files.each do |file|
          modified_files.should include(file)
        end
      end
      
      it 'should not return files not modified from the cache' do
        unexpected_files = @files.values_at(0, 1)
        modified_files = @event.modified_files
        
        unexpected_files.each do |file|
          modified_files.should_not include(file)
        end
      end
      
      it 'should handle this path not yet cached' do
        @dir_cache.delete(@path)
        expected_files = @files
        modified_files = @event.modified_files
        
        expected_files.each do |file|
          modified_files.should include(file)
        end
      end
    end
  end
  
  it 'should list deleted files' do
    @event.should respond_to(:deleted_files)
  end
  
  describe 'listing deleted files' do
    it 'should check the stream mode' do
      @stream.expects(:mode)
      @event.deleted_files
    end
    
    describe 'when the stream mode is mtime' do
      before :each do
        @stream.stubs(:mode).returns(:mtime)
      end
      
      it 'should error' do
        lambda { @event.deleted_files }.should raise_error(RuntimeError)
      end
    end
    
    describe 'when the stream mode is cache' do
      before :each do
        @stream.stubs(:mode).returns(:cache)
      end
      
      before :each do
        @now = Time.now
        @files = Array.new(5) { |i|  stub("file #{i+1}") }
        @event.stubs(:files).returns(@files)
        
        @dir_cache = { @path => {} }
        @files.each_with_index do |file, i|
          size  = 50 * (i + 1)
          mtime = @now + i - 2
          stat = stub("file #{i+1} stat", :mtime => mtime, :size => size)
          @dir_cache[@path][file] = stat
        end
        @stream.stubs(:dirs).returns(@dir_cache)
      end
      
      it 'should get the file list' do
        @event.expects(:files).returns(@files)
        @event.deleted_files
      end
      
      it 'should get the stream dir cache' do
        @stream.expects(:dirs).returns(@dir_cache)
        @event.deleted_files
      end
      
      it 'should get the dir cache for the event path' do
        sub_cache = @dir_cache[@path]
        @dir_cache.expects(:[]).with(@path).returns(sub_cache)
        @event.deleted_files
      end
      
      it 'should return files from the cache that are missing from the file list' do
        expected_files = Array.new(2) { |i|  stub("new file #{i+1}") }
        expected_files.each { |file|  @dir_cache[@path][file] = stub('stat') }
        deleted_files = @event.deleted_files
        
        expected_files.each do |file|
          deleted_files.should include(file)
        end
      end
      
      it 'should not return files from that cache that are present in the file list' do
        unexpected_files = @files
        deleted_files = @event.deleted_files
        
        unexpected_files.each do |file|
          deleted_files.should_not include(file)
        end
      end
      
      it 'should handle this path not yet cached' do
        @dir_cache.delete(@path)
        @event.deleted_files.should == []
      end
    end
  end
end
