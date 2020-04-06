# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle mice faction logic
    class Mouse < Base
      SETUP_PRIORITY = 'C'

      attr_reader :supporters

      attr_buildings :base
      attr_tokens :sympathy

      def faction_symbol
        :mice
      end

      def handle_faction_token_setup
        @meeples = Array.new(10) { Pieces::Meeple.new(:mice) }
        @tokens = Array.new(8) { Mice::Sympathy.new }
        @supporters = []
        handle_base_building
      end

      def handle_base_building
        @buildings = [
          Mice::Base.new(:mouse),
          Mice::Base.new(:bunny),
          Mice::Base.new(:fox)
        ]
      end

      def setup(**_)
        draw_to_supporters(3)
      end

      def draw_to_supporters(num = 1)
        @supporters.concat(deck.draw_from_top(num))
      end
    end
  end
end
