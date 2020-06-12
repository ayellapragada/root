# frozen_string_literal: true

require_relative './base'

module Root
  module Players
    # Handles Computer logic for this.
    class Computer < Base
      # This is silly but I just want a random valid index.
      # In the future we can try and get fancier with this though
      # choice = Computer::Intelligence.make_move(key, opts, @game)
      def pick_option(_key, choices, **)
        if selected.empty?
          choice = choices.sample
          choices.find_index(choice)
        else
          selected.shift
        end
      end

      def be_shown_hand(*); end
    end
  end
end
