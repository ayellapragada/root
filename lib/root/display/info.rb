# frozen_string_literal: true

require 'rainbow'

module Root
  module Display
    # This handles displaying player boards.
    # Horizontal for current, vertical for everyone else.
    class Info
      def self.for_multiple(players)
        res = players.map do |player|
          res = player.faction.formatted_special_info(false)
          res
            .map { |r| r.to_s.split("\n") }
            .map do |arr|
            arr.map { |str| Rainbow(str).fg(player.faction.display_color) }
          end
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
