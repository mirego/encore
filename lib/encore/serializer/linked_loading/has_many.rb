module Encore
  module Serializer
    module LinkedLoading
      module HasMany
        extend ActiveSupport::Concern

        def many(item, reflection)
          item.send("#{reflection.name.to_s.singularize}_ids").map(&:to_s)
        end
      end
    end
  end
end
