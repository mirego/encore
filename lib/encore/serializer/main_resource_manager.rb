module Encore
  module Serializer
    module MainResourceManager
      extend ActiveSupport::Concern

      def self.add(collection, serializer)
        {
          serializer.root_key => collection.map { |o| serializer.new(o).as_json }
        }
      end
    end
  end
end
