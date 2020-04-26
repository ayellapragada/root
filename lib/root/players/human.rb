# frozen_string_literal: true

require_relative './base'

module Root
  module Players
    # Handles user logic for this.
    class Human < Base
      def pick_option(key, options, info: {})
        # :nocov:
        @game&.render(clearings: options)
        # :nocov:
        display.pick_option(key, options, discard: deck.discard, info: info)
      end

      def render_game(game, clearings: nil)
        display.render_game(game, self, clearings)
      end
    end
  end
end
