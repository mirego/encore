module Encore
  module Persister
    module ParamInjection
      def self.inject(payload, injection)
        return payload if injection.nil?

        payload.map do |param|
          injection.reduce(param) do |memo, (key, value)|
            memo.merge key => value
          end
        end
      end
    end
  end
end
