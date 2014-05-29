module Encore
  module Serializer
    class Base < ::ActiveModel::Serializer
      def id
        super.id.to_s
      end

      def links
        output = {}

        object.reflections.each do |_, reflection|
          if reflection.belongs_to?
            output.merge! reflection.name => belongs_to(reflection)
          else
            if add_reflection?(reflection)
              if link = reflection_association(reflection)
                output.merge! reflection.name => link
              end
            end
          end
        end

        output
      end

      def self.can_include
        []
      end

      def self.always_include
        []
      end

      def self.root_key
        model_class.name.pluralize.underscore.to_sym
      end

      def self.key_mappings
        {}
      end

    private

      def add_reflection?(reflection)
        self.class.can_include.include?(reflection.name) || self.class.always_include.include?(reflection.name)
      end

      def belongs_to(reflection)
        object.send(reflection.foreign_key).try(:to_s) if object.respond_to?(reflection.foreign_key)
      end

      def one(reflection)
        object.send(reflection.name).try(:id).try(:to_s)
      end

      def many(reflection)
        object.send("#{reflection.name.to_s.singularize}_ids").map(&:to_s) if object.send(reflection.name).loaded?
      end

      def reflection_association(reflection)
        case reflection.macro
          when :belongs_to then belongs_to(reflection)
          when :has_one then one(reflection)
          when :has_many then many(reflection)
          else
            nil
        end
      end
    end
  end
end
