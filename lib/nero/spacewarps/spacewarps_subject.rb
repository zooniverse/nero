module Nero
  module Spacewarps
    class SpacewarpsSubject < SimpleDelegator
      def category
        return @category if @category

        case attributes.dig("metadata", '#Type')
        when 'SIM', 'DUD'
          'training'
        else
          'test'
        end
      end

      def kind
        return @kind if @kind

        @kind = case attributes.dig("metadata", '#Type')
        when 'SIM'
          "sim"
        when 'DUD'
          "dud"
        else
          "test"
        end
      end

      def test?
        category == 'test'
      end

      def training?
        category == "training"
      end

      def sim?
        kind == 'sim'
      end

      private

      def training
        attributes["metadata"]["training"]
      end
    end
  end
end
