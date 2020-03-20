# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle cats faction logic
    class Cat < Base
      SETUP_PRIORITY = 'A'

      def faction_symbol
        :cats
      end
    end
  end
end
