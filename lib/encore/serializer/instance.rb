require 'encore/serializer/inclusion'
require 'encore/serializer/eager_loading'
require 'encore/serializer/linked_loading'
require 'encore/serializer/linked_serialized'
require 'encore/serializer/links_info'
require 'encore/serializer/main_paging'
require 'encore/serializer/main_serialized'
require 'encore/serializer/paging'

module Encore
  module Serializer
    class Instance
      include Inclusion
      include EagerLoading
      include MainSerialized
      include Paging
      include MainPaging
      include LinkedLoading
      include LinkedSerialized
      include LinksInfo

      def initialize(collection, opts = {})
        @collection = collection
        @includes = parsed_includes(opts[:include])
        @serializers = [serializer]
        @options = parsed_options(opts)
      end

      def as_json(*_)
        # Prepare main collection
        @collection = paginated_collection(@collection, @options)
        @collection = add_eager_loading(@collection, @includes)

        # Fetch linked ids
        linked_ids = add_linked_sets(@collection, @includes)

        # Build final output
        output = add_main_serialized(@collection)
        output.merge! links: add_links_info
        output.merge! linked: add_linked_serialized(linked_ids)
        output.merge! meta: add_main_pagination(@collection, @options)

        output
      end

    private

      def reflections
        @reflections ||= @collection.klass.reflections
      end

      def serializer
        @serializer ||= fetch_serializer(@collection.klass)
      end

      def fetch_serializer(model)
        default_serializer = (model.name.gsub('::', '') + 'Serializer')
        model.active_model_serializer || default_serializer.constantize
      rescue NameError
        raise NameError, "can’t find serializer for #{model.name}, try creating #{default_serializer}"
      end

      def parsed_options(opts)
        {
          skip_paging: opts[:skip_paging].present?,
          page: parse_page(opts[:page]),
          per_page: parse_per_page(opts[:per_page])
        }
      end
    end
  end
end
