# frozen_string_literal: true

require 'rainbow'

module Root
  module Display
    # We currently (and probably will only ever) display to terminal.
    # This handles all of that sort of logic here.
    class Info
      def initialize(player, show_private:)
        @player = player
        @show_private = show_private
      end

      def display
        Rainbow(player.faction.formatted_special_info(show_private))
          .fg(player.faction.display_color)
      end

      private

      attr_reader :player, :show_private
    end
  end
end
