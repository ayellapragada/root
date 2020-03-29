# frozen_string_literal: true

require_relative './base'

module Root
  module Players
    # Handles Computer logic for this.
    class Computer < Base
      # This is silly but I just want a random valid index.
      def pick_option(_key, options)
        $GAME&.render
        choice = options.sample
        options.find_index(choice)
      end

      def render_game(*)
        # Surprise we don't render anything for a computer :wow:
      end
    end
  end
end
