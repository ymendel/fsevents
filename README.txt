= fsevents

  http://rubyforge.org/projects/yomendel/
  http://github.com/ymendel/fsevents

== DESCRIPTION:

  This is intended as a simple, usable FSEvents API. Rather than directly using the Carbon framework and a bunch of methods on OSX, you can pretend you're using a normal Ruby object.

  Much of this was inspired by or almost directly taken from various sources:
  
  * Ezwan Aizat bin Abdullah Faiz's excellent article on using FSEvents with autotest instead of polling -- http://rails.aizatto.com/2007/11/28/taming-the-autotest-beast-with-fsevents/
    This was a major inspiration, especially because (no offense intended) it's so nasty. It shows just how much setup is necessary to do something that should be simple.
  * Rucola's fsevents.rb -- http://rucola.svn.superalloy.nl/browser/r193/trunk/lib/rucola/fsevents.rb
    I was tempted to use this directly, but it's not yet part of the gem. On top of that, requiring Rucola only to use FSEvents seems a little much.
  * rubaidh's fsevent at master -- http://github.com/rubaidh/fsevent/ -- which gave me a few ideas for organization.
  
  If you bother to look, you'll notice the license includes names other than my own. I may have made some improvements and done it all in BDD style, but I had a good foundation to work on. In the words of Isaac Newton, "If I have seen a little further it is by standing on the shoulders of Giants."
  
== SYNOPSIS:

  It doesn't take much to set up an FSEvent stream. At its simplest, it looks like this:
  
      require 'fsevents'
      
      stream = FSEvents::Stream.watch('/tmp') { |events|  p events }
      stream.run
  
  That will enter a loop that continually watches the stream and prints out the events. Try it and make some new files in /tmp.
  
  You may want more details on the events, so just give it a better block.
  
      require 'fsevents'
      
      stream = FSEvents::Stream.watch('/tmp') do |events|
        events.each do |event|
          p event.modified_files
        end
      end
      stream.run
  
  Try that and make some new files in /tmp. Exciting, isn't it?
  
  And for the common case of wanting to process every modified file no matter which subdirectory it happens to be under, the events array is extended for your convenience.
  
      require 'fsevents'
  
      stream = FSEvents::Stream.watch('/tmp') do |events|
        p events.modified_files
      end
      stream.run
  
  FSEvents::Stream.watch takes some options, most of which I fully admit I don't understand because I have little desire to read the documentation on FSEvents itself. One obvious option is latency, which the number of seconds to wait until an event is reported. A higher number allows FSEvents to bundle events.
   
      stream = FSEvents::Stream.watch('/tmp', :latency => 15) {}  # default is 1.0
      
      # Like I said, I don't know what this means. The default is 0, though.
      stream = FSEvents::Stream.watch('/tmp', :flags => 27) {}
      
      stream = FSEvents::Stream.watch('/tmp', '/usr/local') {}  # Yes, you can give multiple paths
      
      stream = FSEvents::Stream.watch  # no path means watch Dir.pwd
  
  FSEvents::Stream.watch is probably the most common entry point, but there are others. You can simply initialize an FSEvents::Stream object with .new, but then the stream needs to be created, scheduled and started. There are a few convenience methods defined to make this easier. The following blocks of code are all equivalent.
  
      stream = FSEvents::Stream.new('/tmp') {}
      stream.create
      stream.schedule
      stream.start
      
      stream = FSEvents::Stream.new('/tmp') {}
      stream.create
      stream.startup
      
      stream = FSEvents::Stream.create('/tmp') {}
      stream.startup
      
      stream = FSEvents::Stream.watch('/tmp') {}

  Just as a stream can be started, it can also be stopped (paused, more like, since apparently you can resume it later).
  
      stream.stop
  
  A stream can also be invalidated and released.
  
      stream.invalidate
      
      stream.release
      
      stream.shutdown  # stops, invalidates, and releases the stream
  
  From what I can tell, entering the run loop requires an interrupt to get back out. Bear that in mind.
  
== REQUIREMENTS:

  * OS X, of course. How exactly were you expecting to use FSEvents?
  * RubyCocoa
  
  Note that the easiest way to have this work is use the stock Ruby install with Leopard.

== INSTALL:

  sudo gem install fsvents
