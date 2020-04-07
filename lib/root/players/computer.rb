# frozen_string_literal: true

require_relative './base'

module Root
  module Players
    # Handles Computer logic for this.
    class Computer < Base
      # This is silly but I just want a random valid index.
      def pick_option(key, options)
        @game&.render(clearings: options)
        choice = options.sample
        options.find_index(choice).tap do
          game.history << format_for_history(key, options, choice) if @game
        end
      end

      def render_game(*)
        # Surprise we don't render anything for a computer :wow:
      end
    end
  end
end
