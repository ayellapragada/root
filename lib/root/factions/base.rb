# frozen_string_literal: true

module Root
  module Factions
    # Interface for basic faction logic
    class Base
      SETUP_PRIORITY = 'ZZZ'

      def setup_priority
        self.class::SETUP_PRIORITY
      end

      def setup(board:, player:); end
    end
  end
end
