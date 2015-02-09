require 'encore/persister/param_injection'
require 'encore/persister/errors_parser'
require 'encore/persister/key_mapping'
require 'encore/persister/links_parser'

module Encore
  module Persister
    class Instance
      include LinksParser
      include ErrorsParser

      attr_reader :errors

      def initialize(model, payload, options = {})
        @model = model
        @payload = payload
        @payload = [@payload] unless payload.is_a?(Array)
        @options = options
        @errors = []
        @ids = Set.new
      end

      def persist!
        @model.transaction do
          process_payload!

          if @errors.any? || @ids.empty?
            raise ActiveRecord::Rollback
          end

          true
        end
      end

      def active_records
        active_record_class.where(id: @ids.to_a.compact)
      end

    private

      def process_payload!
        payload = key_mapping(@payload)
        payload = param_injection(payload)

        payload.each_with_index do |args, i|
          args = parse_links(args)
          record = send(action, args)

          @ids += [record.id]
          @errors += parse_errors(record, i)
        end
      end

      def action
        @model.is_a?(Class) ? 'create_record' : 'update_record'
      end

      def active_record_class
        action == 'create_record' ? @model : @model.class
      end

      def create_record(args)
        @model.create args
      end

      def update_record(args)
        @model.update_attributes(args)
        @model
      end

      def key_mapping(payload)
        @model.active_model_serializer ? KeyMapping.map_keys(payload, @model.active_model_serializer) : payload
      end

      def param_injection(payload)
        ParamInjection.inject(payload, @options[:inject_params])
      end
    end
  end
end
