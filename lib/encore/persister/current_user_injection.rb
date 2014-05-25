module Encore
  module Persister
    module CurrentUserInjection
      def self.inject(params, current_user, as: nil)
        params.map do |param|
          param.merge as => current_user
        end
      end
    end
  end
end
