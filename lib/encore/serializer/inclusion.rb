module Encore
  module Serializer
    module Inclusion
      extend ActiveSupport::Concern

      def parsed_include(option_include)
        output = []

        # Split includes list
        output += option_include.split(',').map(&:to_sym) if option_include.present?

        # Remove resource type not included in 'can_include'
        output = serializer.can_include & output if serializer.respond_to?(:can_include)

        # Add 'always_include' resource type
        output += serializer.always_include if serializer.respond_to?(:always_include)

        output
      end
    end
  end
end
