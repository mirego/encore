module Encore
  module Serializer
    module MainResourceLinksManager
      module ReflectionBelongsTo
        extend ActiveSupport::Concern

        def self.add(item, reflection)
          [item.send(reflection.foreign_key).try(:to_s)]
        end
      end
    end
  end
end
