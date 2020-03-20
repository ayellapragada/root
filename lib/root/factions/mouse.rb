# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle mice faction logic
    class Mouse < Base
      SETUP_PRIORITY = 'C'

      def faction_symbol
        :mice
      end
    end
  end
end
