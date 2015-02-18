module Encore
  module Persister
    module ErrorsParser
      extend ActiveSupport::Concern

      def parse_errors(record, index)
        record.errors.messages.each_with_object([]) do |(field, values), memo|
          data = { path: "#{record.class.name.underscore}/#{index}/#{field}" }
          values.each do |value|
            memo << data.merge(title: value)
          end
        end
      end
    end
  end
end
