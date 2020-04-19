# frozen_string_literal: true

require 'terminal-table'

require_relative './base'
require_relative '../factions/mice/miceable'

module Root
  module Factions
    # Handle mice faction logic
    class Mouse < Base
      include Factions::Mice::Miceable

      SETUP_PRIORITY = 'C'

      attr_reader :supporters, :officers

      attr_buildings :base
      attr_tokens :sympathy

      def faction_symbol
        :mice
      end

      def handle_faction_token_setup
        @meeples = Array.new(10) { Pieces::Meeple.new(:mice) }
        @tokens = Array.new(8) { Mice::Sympathy.new }
        @supporters = []
        @officers = []
        handle_base_building
      end

      def board_title(show_private)
        supporters_text = show_private ? '' : "\n#{supporters.count} Supporters"
        "Outrage | Guerilla Warfare\n#{officers.count} Officers | #{item_list_for_info}#{supporters_text}"
      end

      def special_info(show_private)
        {
          board: {
            title: board_title(show_private),
            rows: board_special_info(show_private),
            headings: [' ', 'Fox', 'Bunny', 'Mouse', 'Bird']
          }
        }
      end

      def formatted_bases
        [
          'Bases',
          display_for_base(:fox),
          display_for_base(:bunny),
          display_for_base(:mouse),
          '-'
        ]
      end

      def display_for_base(suit)
        bases.map(&:suit).include?(suit) ? 'B' : '(+1)'
      end

      def supporters_for(suit)
        supporters.select { |s| s.suit == suit }
      end

      def formatted_supporters
        [
          'Supporters',
          supporters_for(:fox).count.to_s,
          supporters_for(:bunny).count.to_s,
          supporters_for(:mouse).count.to_s,
          supporters_for(:bird).count.to_s
        ]
      end

      def board_special_info(show_private)
        rows = []
        rows << formatted_bases
        rows << formatted_supporters if show_private
        rows
      end

      def handle_base_building
        @buildings = [
          Mice::Base.new(:fox),
          Mice::Base.new(:bunny),
          Mice::Base.new(:mouse)
        ]
      end

      def setup(**_)
        draw_to_supporters(3)
      end

      def draw_to_supporters(num = 1)
        @supporters.concat(deck.draw_from_top(num))
      end

      # Overwrites the attr_buildings
      def place_base(suit, clearing)
        base = bases.find { |b| b.suit == suit }
        place_building(base, clearing)
      end
    end
  end
end
