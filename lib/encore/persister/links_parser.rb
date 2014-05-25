module Encore
  module Persister
    module LinksParser
      extend ActiveSupport::Concern

      def parse_links(args)
        links = args.delete(:links) || []

        links.each do |link, value|
          reflection = @model.reflections[link.to_sym]
          key = fetch_key(reflection)

          args.merge!(key => value) if key
        end

        args
      end

    private

      def link_belongs_to(reflection)
        reflection.foreign_key.to_sym
      end

      def link_has_many(reflection)
        "#{reflection.name.to_s.singularize}_ids".to_sym
      end

      def fetch_key(reflection)
        case reflection.macro
          when :belongs_to then link_belongs_to(reflection)
          when :has_many then link_has_many(reflection)
          else
            nil
        end
      end
    end
  end
end
