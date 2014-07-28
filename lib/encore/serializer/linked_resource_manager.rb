require 'encore/serializer/utils'

module Encore
  module Serializer
    module LinkedResourceManager
      extend ActiveSupport::Concern

      def self.add(linked_ids, object)
        included_models = linked_ids.keys.map { |key| key.downcase }
        included_models << object.klass.name.downcase

        linked_ids.reduce({}) do |memo, (model, ids)|
          klass = model.constantize
          serializer = Utils.fetch_serializer(klass)

          collection = klass.where(id: ids.to_a)
          reflections = klass.try(:_reflections) || klass.reflections
          available_includes = reflections.map do |key, _|
            next unless included_models.include?(key.to_s)
            key
          end.compact

          collection = collection.includes(available_includes) unless available_includes.empty?
          memo.merge! MainResourceManager.add(collection, serializer)
        end
      end
    end
  end
end
