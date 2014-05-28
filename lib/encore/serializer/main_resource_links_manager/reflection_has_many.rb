module Encore
  module Serializer
    module MainResourceLinksManager
      module ReflectionHasMany
        extend ActiveSupport::Concern

        def self.add(item, reflection)
          item.send("#{reflection.name.to_s.singularize}_ids").map(&:to_s)
        end
      end
    end
  end
end
