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
          memo.merge! serializer.root_key => collection.map { |c| serializer.new(c).as_json }
        end
      end
    end
  end
end
