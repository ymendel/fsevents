require File.dirname(__FILE__) + '/spec_helper.rb'

describe EventArray do
  before :each do
    @event_array = []
    @event_array.extend(EventArray)
  end
  
  it 'should return files' do
    @event_array.should respond_to(:files)
  end
  
  describe 'returning files' do
    it 'should collect files from its events' do
      events = Array.new(3) { stub('event', :files => Array.new(3) { stub('file') }) }
      files = []
      events.each do |event|
        @event_array << event
        files += event.files
      end
      
      @event_array.files.should == files
    end
  end
  
  it 'should return modified files' do
    @event_array.should respond_to(:modified_files)
  end
  
  describe 'returning modified files' do
    it 'should collect modified files from its events' do
      events = Array.new(3) { stub('event', :modified_files => Array.new(3) { stub('file') }) }
      files = []
      events.each do |event|
        @event_array << event
        files += event.modified_files
      end
      
      @event_array.modified_files.should == files
    end
  end
  
  it 'should return deleted files' do
    @event_array.should respond_to(:deleted_files)
  end
  
  describe 'returning deleted files' do
    it 'should collect deleted files from its events' do
      events = Array.new(3) { stub('event', :deleted_files => Array.new(3) { stub('file') }) }
      files = []
      events.each do |event|
        @event_array << event
        files += event.deleted_files
      end
      
      @event_array.deleted_files.should == files
    end
  end
end
