module FSEvents
  class Event
    attr_reader :id, :path, :stream
    
    def initialize(id, path, stream)
      @id     = id
      @path   = path
      @stream = stream
    end
    
    def files
      Dir["#{path}/*"]
    end
  end
end