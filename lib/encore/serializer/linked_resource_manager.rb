require 'encore/serializer/utils'

module Encore
  module Serializer
    module LinkedResourceManager
      extend ActiveSupport::Concern

      def self.add(linked_ids)
        linked_ids.reduce({}) do |memo, (model, ids)|
          klass = model.constantize
          serializer = Utils.fetch_serializer(klass)

          collection = klass.where(id: ids.to_a)
          memo.merge! MainResourceManager.add(collection, serializer)
        end
      end
    end
  end
end
