$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'osx/foundation'
OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'

require 'fsevents/ext'
require 'fsevents/stream'

module FSEvents
end
