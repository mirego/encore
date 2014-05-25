require 'encore/serializer/linked_loading/belongs_to'
require 'encore/serializer/linked_loading/has_many'
require 'encore/serializer/linked_loading/has_one'

module Encore
  module Serializer
    module LinkedLoading
      extend ActiveSupport::Concern
      include HasMany
      include HasOne
      include BelongsTo

      def add_linked_sets(collection, includes)
        collection.reduce(Hash.new(Set.new)) do |memo, resource|
          includes.each do |inclusion|
            model, ids = association_collection(resource, inclusion)
            memo[model] += ids
          end

          memo
        end
      end

    private

      def association_collection(item, inclusion)
        reflection = reflections[inclusion]
        class_name = fetch_class_name(item, reflection)

        collection = begin
          case reflection.macro
            when :belongs_to then belongs_to(item, reflection)
            when :has_one then one(item, reflection)
            when :has_many then many(item, reflection)
          end
        end

        [class_name, collection.flatten.compact]
      end

      def fetch_class_name(item, reflection)
        if reflection.options[:polymorphic]
          item.send(reflection.foreign_type).constantize.to_s
        else
          reflection.klass.name.to_s
        end
      end
    end
  end
end
