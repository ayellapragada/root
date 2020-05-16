# frozen_string_literal: true

require 'rainbow'
require 'terminal-table'

module Root
  module Display
    # Handle the display logic for the history object
    class History
      MAX_NUMBER_OF_MAP_LINES = 29

      def initialize(history)
        @history = history
      end

      # player, key, opts
      def display
        ::Terminal::Table.new(
          title: 'History',
          rows: rows,
          style: { width: 80 }
        )
      end

      def rows
        viewable_history.map do |hist|
          next [' '] if hist == ' '

          res = [
            hist[:player],
            Messages::LIST[hist[:key]][:history] % hist[:opts].values
          ].join(' | ')

          [Rainbow(res).fg(hist[:color])]
        end
      end

      def viewable_history
        pad_history(history.last(MAX_NUMBER_OF_MAP_LINES))
      end

      private

      def pad_history(array)
        padded = MAX_NUMBER_OF_MAP_LINES - array.count
        padded.times { array << ' ' }
        array
      end

      attr_reader :history
    end
  end
end
