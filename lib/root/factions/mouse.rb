# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle mice faction logic
    class Mouse < Base
      SETUP_PRIORITY = 'C'

      alias_method :sympathy, :tokens

      attr_reader :supporters

      def faction_symbol
        :mice
      end

      def handle_faction_token_setup
        @meeples = Array.new(10) { Pieces::Meeple.new(:mouse) }
        @tokens = Array.new(8) { Mice::Sympathy.new }
        @supporters = []
        handle_base_building
      end

      def handle_base_building
        @buildings = [
          Mice::Base.new(:mouse),
          Mice::Base.new(:rabbit),
          Mice::Base.new(:fox)
        ]
      end

      def bases
        @bases ||= buildings.select { |b| b.type == :base }
      end

      def setup(deck:, **_)
        draw_to_supporters(deck, 3)
      end

      def draw_to_supporters(deck, num = 1)
        @supporters.concat(deck.draw_from_top(num).map(&:suit))
      end
    end
  end
end
