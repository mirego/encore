require 'encore/persister/current_user_injection'
require 'encore/persister/errors_parser'
require 'encore/persister/key_mapping_for_update'
require 'encore/persister/links_parser'

module Encore
  module Persister
    class Base
      include LinksParser
      include ErrorsParser

      attr_reader :errors

      def initialize(model, payload)
        @model = model
        @payload = payload
        @errors = []
        @ids = Set.new
      end

      def persist!
        !!@model.transaction do
          procces_payload!(action)

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

      def procces_payload!(action)
        @payload.each_with_index do |args, i|
          args = parse_links(args)
          record = send("#{action}_record", args)

          if record.present?
            @ids += fetch_id(record)
            @errors += parse_errors(record, i)
          end
        end
      end

      def active_record_class
        @model.is_a?(Class) ? @model : @model.class
      end

      def action
        @model.is_a?(Class) ? :create : :update
      end

      def create_record(args)
        @model.create args
      end

      def update_record(args)
        @model.update_attributes(args)
        @model
      end

      def fetch_id(record)
        [record.id]
      end
    end
  end
end
