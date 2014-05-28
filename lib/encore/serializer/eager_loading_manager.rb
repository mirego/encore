module Encore
  module Serializer
    module EagerLoadingManager
      extend ActiveSupport::Concern

      def self.add(collection, option_include)
        collection.includes(option_include)
      end
    end
  end
end
