module Encore
  module Inclusion
    extend ActiveSupport::Concern

    def parsed_includes(includes)
      output = Set.new

      if includes.present?
        output += includes.split(',').map(&:to_sym)
      end

      output += serializer.always_include

      output.to_a
    end
  end
end
