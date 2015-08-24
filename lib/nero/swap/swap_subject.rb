module Nero
  module Swap
    class SwapSubject < SimpleDelegator
      def category
        return @category if @category

        if training && training.count > 0 && training.first["type"]
          @category = 'training'
        else
          @category = 'test'
        end
      end

      def kind
        return @kind if @kind

        if training && training.count > 0 && training.first["type"]
          if ["lensing cluster", "lensed quasar", "lensed galaxy"].include? training.first["type"]
            @kind     = 'sim'
          elsif  training.first["type"] == "empty"
            @kind     = 'dud'
          else
            @kind = 'test'
          end
        else
          @kind = 'test'
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
