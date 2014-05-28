module Encore
  module Serializer
    class OptionsParser
      def initialize(opts)
        @opts = opts
      end

      def include(serializer)
        opt = @opts[:include]

        output = []

        # Split includes list
        output += opt.split(',').map(&:to_sym) if opt.present?

        # Remove resource type not included in 'can_include'
        output = serializer.can_include & output if serializer.respond_to?(:can_include)

        # Add 'always_include' resource type
        output += serializer.always_include if serializer.respond_to?(:always_include)

        output
      end

      def page
        opt = @opts[:page]

        opt.present? ? opt.to_i : 1
      end

      def per_page
        opt = @opts[:per_page]

        return Kaminari.config.default_per_page if opt.nil?

        max_per_page = Kaminari.config.max_per_page.to_i
        opt = opt.to_i

        if max_per_page.zero?
          opt
        else
          opt > max_per_page ? max_per_page : opt
        end
      end

      def skip_paging
        @opts[:skip_paging].present?
      end
    end
  end
end
