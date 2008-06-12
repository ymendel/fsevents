module FSEvents
  class Stream
    def initialize(path, options = {})
      OSX.FSEventStreamCreate
    end
  end
end
