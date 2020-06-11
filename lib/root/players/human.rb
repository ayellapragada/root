# frozen_string_literal: true

require_relative './base'

module Root
  module Players
    # Handles user logic for this.
    class Human < Base
      def pick_option(*)
        selected.pop
      end

      def be_shown_hand(hand)
        # display.be_shown_hand(hand)
      end
    end
  end
end
