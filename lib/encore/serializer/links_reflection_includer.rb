module Encore
  module Serializer
    module LinksReflectionIncluder
      module Loaded
        def self.reflection_belongs_to(object, reflection)
          object.send(reflection.foreign_key).try(:to_s) if object.respond_to?(reflection.foreign_key)
        end

        def self.reflection_has_one(object, reflection)
          object.send(reflection.name).try(:id).try(:to_s)
        end

        def self.reflection_has_many(object, reflection)
          object.send("#{reflection.name.to_s.singularize}_ids").map(&:to_s) if object.send(reflection.name).loaded?
        end
      end

      module NotLoaded
        def self.reflection_has_many(object, reflection)
          reflection_type = plural_path(reflection.klass)

          {
            href: "/#{reflection_type}?#{object.class.name.underscore}_id=#{object.id}",
            type: reflection_type
          }
        end

        def self.reflection_has_one(object, reflection)
          root_type = plural_path(object.class)
          reflection_type = singular_path(reflection.klass)

          {
            href: "/#{root_type}/#{object.id}/#{reflection_type}",
            type: reflection_type.pluralize
          }
        end

        def self.reflection_belongs_to(object, reflection)
          reflection_type = plural_path(reflection.klass)
          reflection_id = object.send(reflection.foreign_key).try(:to_s)

          return nil if reflection_id.blank?

          {
            href: "/#{reflection_type}/#{reflection_id}",
            id: reflection_id,
            type: reflection_type
          }
        end

      private

        def self.plural_path(klass)
          klass.active_model_serializer.root_key.to_s
        end

        def self.singular_path(klass)
          plural_path(klass).singularize
        end
      end
    end
  end
end
