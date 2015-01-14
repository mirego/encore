module Encore
  module Persister
    module LinksParser
      extend ActiveSupport::Concern

      def parse_links(args)
        links = args.delete(:links) || []

        links.each do |link, value|
          reflections = @model.try(:_reflections) || @model.reflections
          reflection = reflections[link.to_s] || reflections[link.to_sym]
          key = fetch_key(reflection)
          value = fetch_value(value, reflection)

          args.merge!(key => value) if key
        end

        args
      end

    private

      # `belongs_to` => 'user' become 'user_id'
      def link_belongs_to(reflection)
        reflection.foreign_key.to_sym
      end

      # `has_many` => 'users' become 'user_ids'
      def link_has_many(reflection)
        "#{reflection.name.to_s.singularize}_ids".to_sym
      end

      # `has_one` => 'user' stay 'user'
      def link_has_one(reflection)
        reflection.name
      end

      # Convert reflection with the right ActiveRecord key for insert/update.
      def fetch_key(reflection)
        case reflection.macro
          when :belongs_to then link_belongs_to(reflection)
          when :has_many then link_has_many(reflection)
          when :has_one then link_has_one(reflection)
        end
      end

      # Value for `has_one` must be an activerecord instance.
      # Other reflection macro types stay the same.
      def fetch_value(value, reflection)
        if reflection.macro == :has_one
          reflection.klass.find(value)
        else
          value
        end
      end
    end
  end
end
