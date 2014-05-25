module Encore
  module Serializer
    module MainPaging
      extend ActiveSupport::Concern

      def add_main_pagination(collection)
        {
          serializer.root_key => pagination_for(collection)
        }
      end
    end
  end
end
