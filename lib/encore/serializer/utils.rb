module Encore
  module Serializer
    module Utils
      def self.fetch_serializer(model)
        default_serializer = (model.name.gsub('::', '') + 'Serializer')
        model.active_model_serializer || default_serializer.constantize
      rescue NameError
        raise NameError, "can’t find serializer for #{model.name}, try creating #{default_serializer}"
      end
    end
  end
end
