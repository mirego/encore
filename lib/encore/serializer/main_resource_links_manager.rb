require 'encore/serializer/main_resource_links_manager/reflection_belongs_to'
require 'encore/serializer/main_resource_links_manager/reflection_has_many'
require 'encore/serializer/main_resource_links_manager/reflection_has_one'

module Encore
  module Serializer
    module MainResourceLinksManager
      extend ActiveSupport::Concern

      def self.add(collection, reflections, option_include)
        collection.each_with_object(Hash.new(Set.new)) do |resource, memo|
          option_include.each do |inclusion|
            model, ids = association_collection(resource, inclusion, reflections)
            memo[model] += ids
          end
        end
      end

    private

      def self.association_collection(item, inclusion, reflections)
        reflection = reflections[inclusion]
        class_name = fetch_class_name(item, reflection)

        collection = begin
          case reflection.macro
            when :belongs_to then ReflectionBelongsTo.add(item, reflection)
            when :has_one then ReflectionHasOne.add(item, reflection)
            when :has_many then ReflectionHasMany.add(item, reflection)
          end
        end

        [class_name, collection.flatten.compact]
      end

      def self.fetch_class_name(item, reflection)
        if reflection.options[:polymorphic]
          item.send(reflection.foreign_type).constantize.to_s
        else
          reflection.klass.name.to_s
        end
      end
    end
  end
end
