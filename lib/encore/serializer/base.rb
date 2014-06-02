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
      def self.can_include
        []
      end

      # Specify which resources the API always include in the "linked" top-level key.
      def self.always_include
        []
      end

      # Specify which resources the API exposes URL to.
      # Default is can_include + always_include.
      def self.can_access
        can_include | always_include
      end

      def self.root_key
        model_class.name.pluralize.underscore.to_sym
      end

      def self.key_mappings
        {}
      end
    end
  end
end
