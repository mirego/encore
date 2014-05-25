module Encore
  module Serializer
    module LinkedLoading
      module BelongsTo
        extend ActiveSupport::Concern

        def belongs_to(item, reflection)
          [item.send(reflection.foreign_key).try(:to_s)]
        end
      end
    end
  end
end
