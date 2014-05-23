module Encore
  module LinkedSerialized
    extend ActiveSupport::Concern

    def add_linked_serialized(linked_ids)
      linked_ids.reduce({}) do |memo, (model, ids)|
        klass = model.constantize
        serializer = fetch_serializer(klass)
        @serializers << serializer

        collection = klass.where(id: ids.to_a)
        @linked_collections ||= {}
        @linked_collections[model] = collection

        memo.merge! serializer.root_key => collection.map { |c| serializer.new(c).as_json }
      end
    end
  end
end
