require 'encore/serializer/utils'

module Encore
  module Serializer
    module LinkedResourceManager
      extend ActiveSupport::Concern

      def self.add(linked_ids, object)
        included_models = linked_ids.keys.map { |model| model.downcase }
        included_models << object.klass.name.downcase

        linked_ids.reduce({}) do |memo, (model, ids)|
          klass = model.constantize
          serializer = Utils.fetch_serializer(klass)

          collection = klass.where(id: ids.to_a)
          available_includes = klass.reflections.map do |model, _|
            next unless included_models.include?(model.to_s)
            model
          end.compact

          collection = collection.includes(available_includes) unless available_includes.empty?
          memo.merge! MainResourceManager.add(collection, serializer)
        end
      end
    end
  end
end
