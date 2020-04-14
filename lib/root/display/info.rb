# frozen_string_literal: true

require 'rainbow'

module Root
  module Display
    # We currently (and probably will only ever) display to terminal.
    # This handles all of that sort of logic here.
    class Info
      def self.for_multiple(players)
        players.map do |player|
          player_info = new(player, show_private: false)
          player_info
            .format(player.faction.formatted_special_info(false))
            .split("\n")
            .map { |str| Rainbow(str).fg(player.faction.display_color) }
        end.flatten
      end

      def initialize(player, show_private:)
        @player = player
        @show_private = show_private
      end

      def display
        res = player.faction.formatted_special_info(show_private)
        Rainbow(format(res)).fg(player.faction.display_color)
      end

      def format(tables)
        board, *rest = *tables
        split_board = split_and_format_board(board)
        split_rest = rest.map { |re| split_and_format_board(re) }
        better_zip_for_arrays(split_board, *split_rest).join("\n")
      end

      def better_zip_for_arrays(*arrays)
        res = []
        arrays.map(&:length).max.times do |i|
          res << (arrays.map do |arr|
            arr[i] || (' ' * arr[0].length)
          end).join(' ')
        end
        res
      end

      def split_and_format_board(board)
        board.to_s.split("\n")
      end

      private

      attr_reader :player, :show_private
    end
  end
end
