require 'encore/serializer/links_reflection_includer'

module Encore
  module Serializer
    class Base < ::ActiveModel::Serializer
      attributes :links

      def id
        object.id.to_s
      end

      def links
        object.reflections.each_with_object({}) do |(_, reflection), memo|
          if object.association(reflection.name).loaded?
            fetcher = LinksReflectionIncluder::Loaded
          else
            next unless self.class.can_access.include?(reflection.name)
            fetcher = LinksReflectionIncluder::NotLoaded
          end

          memo.merge!(reflection.name => fetcher.send("reflection_#{reflection.macro}", object, reflection))
        end
      end

      # Specify which resources the API can be included in the "linked" top-level key.
      def self.can_include(*value)
        if value.any?
          @can_include = value.flatten
        else
          @can_include ||= []
        end
      end

      # Specify which resources the API always include in the "linked" top-level key.
      def self.always_include(*value)
        if value.any?
          @always_include = value.flatten
        else
          @always_include ||= []
        end
      end

      # Specify which resources the API exposes URL to.
      # Default is can_include + always_include.
      def self.can_access(*value)
        if value.any?
          @can_access = value.flatten
        else
          @can_access ||= can_include | always_include
        end
      end

      def self.root_key(value = nil)
        if value
          @root_key = value
        else
          @root_key ||= model_class.name.pluralize.underscore.to_sym
        end
      end

      def self.key_mappings(value = nil)
        if value
          @key_mappings = value
        else
          @key_mappings ||= {}
        end
      end
    end
  end
end
