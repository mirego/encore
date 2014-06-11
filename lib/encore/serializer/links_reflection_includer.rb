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
          reflection_type = reflection.name.to_s.pluralize

          {
            href: "/#{reflection_type}?#{object.class.name.underscore}_id=#{object.id}",
            type: reflection_type
          }
        end

        def self.reflection_has_one(object, reflection)
          reflection_type = reflection.name.to_s

          {
            href: "/#{object.class.name.underscore.pluralize}/#{object.id}/#{reflection_type}",
            type: reflection_type.pluralize
          }
        end

        def self.reflection_belongs_to(object, reflection)
          reflection_type = reflection.name.to_s.pluralize
          reflection_id = object.send(reflection.foreign_key).try(:to_s)

          {
            href: "/#{reflection_type}/#{reflection_id}",
            id: reflection_id,
            type: reflection_type
          }
        end
      end
    end
  end
end
