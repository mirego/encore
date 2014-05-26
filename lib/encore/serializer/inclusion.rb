module Encore
  module Serializer
    module Inclusion
      extend ActiveSupport::Concern

      def parsed_includes(includes)
        output = Set.new

        if includes.present?
          output += includes.split(',').map(&:to_sym)
        end

        if serializer.respond_to?(:always_include)
          output += serializer.always_include
        end

        output.to_a
      end
    end
  end
end
