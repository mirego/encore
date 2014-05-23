module Encore
  module MainSerialized
    extend ActiveSupport::Concern

    def add_main_serialized(collection)
      {
        serializer.root_key => collection.map { |o| serializer.new(o).as_json }
      }
    end
  end
end
