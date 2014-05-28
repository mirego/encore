module Encore
  module Serializer
    module MainResourceLinksManager
      module ReflectionHasOne
        extend ActiveSupport::Concern

        def self.add(item, reflection)
          [item.send(reflection.name).try(:id).try(:to_s)]
        end
      end
    end
  end
end
