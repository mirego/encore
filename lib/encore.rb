require 'encore/version'

require 'active_model_serializers'
require 'active_record'
require 'active_support'

# This is a dirty hack to fix dirty code
# https://github.com/amatsuda/kaminari/blob/7b049067b143212a172d5bb472184eac23121f34/lib/kaminari.rb#L11-L25
oldstderr = $stderr.dup
$stderr = StringIO.new
require 'kaminari'
$stderr = oldstderr

require 'encore/config'

require 'encore/serializer/base'
require 'encore/serializer/instance'
require 'encore/persister/instance'

module Encore
end
