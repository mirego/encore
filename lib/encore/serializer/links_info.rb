module Encore
  module Serializer
    module LinksInfo
      extend ActiveSupport::Concern

      def add_links_info
        [serializer, *@serializers].reduce({}) do |memo, serializer|
          root = serializer.root_key
          model = serializer.model_class

          serializer.can_access.each do |include|
            reflection = model.reflections[include]
            type = reflection.klass.name.underscore.pluralize

            memo.merge! key(root, reflection) => { href: href(root, reflection), type: type }
          end

          memo
        end
      end

    private

      def key(root, reflection)
        "#{root.to_s.pluralize}.#{reflection.name}"
      end

      def href(root, reflection)
        if reflection.belongs_to?
          belongs_to_href(root, reflection)
        else
          many_href(root, reflection)
        end
      end

      def belongs_to_href(root, reflection)
        "/#{reflection.plural_name}/{#{root}.links.#{reflection.name}}"
      end

      def many_href(root, reflection)
        "/#{reflection.plural_name}?#{root}_id={#{root}.id}"
      end
    end
  end
end
