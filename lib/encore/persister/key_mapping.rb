module Encore
  module Persister
    module KeyMapping
      def self.map_keys(array_params, serializer)
        array_params.map do |params|
          mappings = serializer.key_mappings

          params.keys.each { |k| params[mappings[k]] = params.delete(k) if mappings[k] }

          params
        end
      end
    end
  end
end
