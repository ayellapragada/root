# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle vagabond faction logic
    class Vagabond < Base
      SETUP_PRIORITY = 'D'

      def faction_symbol
        :vagabond
      end

      def items
        []
      end

      def damaged_items
        []
      end

      def teas
        []
      end

      def coins
        []
      end

      def bags
        []
      end
    end
  end
end
