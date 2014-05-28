require 'encore/serializer/eager_loading_manager'
require 'encore/serializer/linked_resource_manager'
require 'encore/serializer/main_resource_manager'
require 'encore/serializer/main_resource_links_manager'
require 'encore/serializer/links_manager'
require 'encore/serializer/meta_manager'
require 'encore/serializer/utils'
require 'encore/serializer/options_parser'

module Encore
  module Serializer
    class Instance
      def initialize(collection, opts = {})
        @collection = collection
        @serializers = [serializer]
        @options = parsed_options(opts)
      end

      def as_json(*_)
        # Prepare main collection
        @collection = MetaManager.paginate_collection(@collection, @options)
        @collection = EagerLoadingManager.add(@collection, @options[:include])

        # Fetch linked ids
        linked_ids = MainResourceLinksManager.add(@collection, reflections, @options[:include])

        # Build final output
        output = MainResourceManager.add(@collection, serializer)
        output.merge! links: LinksManager.add(serializer, @serializers)
        output.merge! linked: LinkedResourceManager.add(linked_ids)
        output.merge! meta: MetaManager.add(@collection, serializer, @options)

        output
      end

    private

      def reflections
        @reflections ||= @collection.klass.reflections
      end

      def serializer
        @serializer ||= Utils.fetch_serializer(@collection.klass)
      end

      def parsed_options(opts)
        parser = OptionsParser.new(opts)

        {
          include: parser.include(serializer),
          skip_paging: parser.skip_paging,
          page: parser.page,
          per_page: parser.per_page
        }
      end
    end
  end
end
