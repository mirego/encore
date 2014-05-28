module Encore
  module Serializer
    module LinksManager
      extend ActiveSupport::Concern

      def self.add(serializer, serializers)
        [serializer, *serializers].each_with_object({}) do |item, memo|
          root = item.root_key
          model = item.model_class

          item.can_access.each do |include|
            next unless reflection = model.reflections[include]

            type = reflection.klass.name.underscore.pluralize
            memo.merge! key(root, reflection) => { href: href(root, reflection), type: type }
          end
        end
      end

    private

      def self.key(root, reflection)
        "#{root.to_s.pluralize}.#{reflection.name}"
      end

      def self.href(root, reflection)
        if reflection.belongs_to?
          belongs_to_href(root, reflection)
        else
          many_href(root, reflection)
        end
      end

      def self.belongs_to_href(root, reflection)
        "/#{reflection.plural_name}/{#{root}.links.#{reflection.name}}"
      end

      def self.many_href(root, reflection)
        "/#{reflection.plural_name}?#{root}_id={#{root}.id}"
      end
    end
  end
end
