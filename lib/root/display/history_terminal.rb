require 'rainbow'

module Root
  module Display
    # Handle the display logic for the history object
    class HistoryTerminal
      def initialize(history)
        @history = history
      end

      def display
        history.last(5).map do |hist|
          res = [hist[:player], hist[:key], try_quick_inspect(hist[:choice])]
          res << hist[:options].map { |obj| try_quick_inspect(obj) }.join(' | ')
          res.join(' :: ')[0..90]
        end
      end

      def try_quick_inspect(obj)
        obj.respond_to?(:quick_inspect) ? obj.quick_inspect : obj.inspect
      end

      private

      attr_reader :history
    end
  end
end
