module Encore
  module EagerLoading
    extend ActiveSupport::Concern

    def add_eager_loading(collection, includes)
      collection.includes(includes)
    end
  end
end