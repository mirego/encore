module Encore
  module Serializer
    module Paging
      extend ActiveSupport::Concern

      def paginated_collection(collection, options)
        return collection if options[:skip_paging]

        collection.page(options[:page]).per(options[:per_page])
      end

      def pagination_for(collection)
        {
          page: collection.current_page,
          count: collection.total_count,
          page_count: collection.num_pages,
          previous_page: collection.prev_page,
          next_page: collection.next_page
        }
      end

      def parse_page(page)
        return 1 if page.nil?

        page.to_i
      end

      def parse_per_page(per_page)
        return Kaminari.config.default_per_page if per_page.nil?

        max_per_page = Kaminari.config.max_per_page.to_i
        per_page = per_page.to_i

        if max_per_page.zero?
          per_page
        else
          per_page > max_per_page ? max_per_page : per_page
        end
      end
    end
  end
end
