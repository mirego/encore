module Encore
  module Persister
    module ErrorsParser
      extend ActiveSupport::Concern

      def parse_errors(record, index)
        record.errors.messages.map do |field, values|
          {
            field: field.to_s,
            types: values,
            path: "#{record.class.name.underscore}/#{index}/#{field}"
          }
        end
      end
    end
  end
end
