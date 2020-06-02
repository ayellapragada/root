# frozen_string_literal: true

require_relative './base'

module Root
  module Players
    # Handles user logic for this.
    class Human < Base
      def pick_option(key, options, info: {})
        display.pick_option(key, options, player: self, game: @game, info: info)
      end

      def be_shown_hand(hand)
        display.be_shown_hand(hand)
      end
    end
  end
end
