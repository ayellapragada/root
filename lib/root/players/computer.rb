# frozen_string_literal: true

require_relative './base'

module Root
  module Players
    # Handles Computer logic for this.
    class Computer < Base
      # This is silly but I just want a random valid index.
      def pick_option(_key, options)
        @game&.render(clearings: options)
        choice = options.sample
        options.find_index(choice)
      end

      # Easier "SMART" mode:
      # choice = Computer::Intelligence.make_move(key, opts, @game)
      # Maybe don't even necessarily do the CWE. Just do the bots.
      # Don't even necessarily have to be _great_ but playable would be neat,
      # lots of common major logic workflows,
      # like when to do thing or not do things
      # after that, simple enough to use some common CWE tricks,
      # such as clearing priorities.

      def render_game(*)
        # Surprise we don't render anything for a computer :wow:
      end
    end
  end
end
