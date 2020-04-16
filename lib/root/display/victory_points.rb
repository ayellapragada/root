# frozen_string_literal: true

require 'rainbow'

module Root
  module Display
    # Handle logic for showing the victory points
    # Either stack, or all one square?
    # Some way to handle it so it's not shifting constantly.
    class VictoryPoints
      def initialize(players)
        @players = players
      end

      def display
        ::Terminal::Table.new(
          # headings: %w[Faction VP],
          rows: rows
        )
      end

      def rows
        [
          players.victory_points.map do |player|
            info = "#{player[:faction].to_s.capitalize}: #{player[:victory_points]}"
            Rainbow(info).fg(player[:color])
          end
        ]
      end

      attr_reader :players
    end
  end
end