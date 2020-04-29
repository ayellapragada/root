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
          headings: %w[Faction VP],
          rows: rows,
          style: { width: 22 }
        )
      end

      def rows
        players
          .victory_points
          .sort_by { |p| p[:victory_points] }
          .reverse
          .map do |player|
          [
            Rainbow(player[:faction].to_s.capitalize).fg(player[:color]),
            Rainbow(player[:victory_points]).fg(player[:color])
          ]
        end
      end

      attr_reader :players
    end
  end
end
