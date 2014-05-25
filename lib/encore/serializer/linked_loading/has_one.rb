module Encore
  module Serializer
    module LinkedLoading
      module HasOne
        extend ActiveSupport::Concern

        def one(item, reflection)
          [item.send(reflection.name).try(:id).try(:to_s)]
        end
      end
    end
  end
end
