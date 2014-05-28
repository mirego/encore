module Encore
  module Serializer
    module MetaManager
      extend ActiveSupport::Concern

      def self.paginate_collection(collection, options)
        return collection if options[:skip_paging]

        collection.page(options[:page]).per(options[:per_page])
      end

      def self.add(collection, serializer, options)
        return {} if options[:skip_paging]

        { serializer.root_key => pagination_for(collection) }
      end

      def self.pagination_for(collection)
        {
          page: collection.current_page,
          count: collection.total_count,
          page_count: collection.num_pages,
          previous_page: collection.prev_page,
          next_page: collection.next_page
        }
      end
    end
  end
end
