# frozen_string_literal: true

require_relative './base'

module Root
  module Players
    # Handles user logic for this.
    class Human < Base
      def pick_option(key, options)
        $GAME&.render(clearings: options)
        display.pick_option(key, options)
      end

      def render_game(game, clearings: nil)
        display.render_game(game, self, clearings)
      end
    end
  end
end
