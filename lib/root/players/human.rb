# frozen_string_literal: true

require_relative './base'

module Root
  module Players
    # Handles user logic for this.
    class Human < Base
      def pick_option(key, options)
        $GAME&.render
        display.pick_option(key, options)
      end

      def render_game(game)
        display.render_game(game, self)
      end
    end
  end
end
