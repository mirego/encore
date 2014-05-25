module Encore
  module Persister
    module KeyMappingForUpdate
      def self.map_keys(params, serializer)
        params = params[0]
        mappings = serializer.key_mappings

        params.keys.each { |k| params[mappings[k]] = params.delete(k) if mappings[k] }

        [params]
      end
    end
  end
end
