module Encore
  module Serializer
    module MainPaging
      extend ActiveSupport::Concern

      def add_main_pagination(collection, options)
        return {} if options[:skip_paging]

        {
          serializer.root_key => pagination_for(collection)
        }
      end
    end
  end
end
