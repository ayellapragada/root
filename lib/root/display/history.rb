# frozen_string_literal: true

require 'rainbow'

module Root
  module Display
    # Handle the display logic for the history object
    class History
      MAX_NUMBER_OF_MAP_LINES = 33
      # MAX_NUMBER_OF_MAP_LINES = 7
      def initialize(history)
        @history = history
      end

      # player, key, opts
      def display
        history.last(MAX_NUMBER_OF_MAP_LINES).map do |hist|
          res = [
            hist[:player],
            Messages::LIST[hist[:key]][:history] % hist[:opts].values
          ].join(' | ')

          Rainbow(res).fg(hist[:color])
        end
      end

      private

      attr_reader :history
    end
  end
end
