# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle birds faction logic
    class Bird < Base
      SETUP_PRIORITY = 'B'

      def faction_symbol
        :birds
      end
    end
  end
end
