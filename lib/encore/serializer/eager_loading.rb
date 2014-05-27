module Encore
  module Serializer
    module EagerLoading
      extend ActiveSupport::Concern

      def add_eager_loading(collection, option_include)
        collection.includes(option_include)
      end
    end
  end
end
