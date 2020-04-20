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

      # Actually tokens but ya feel me
      BUILDINGS = 10

      attr_reader :supporters, :officers

      attr_buildings :base
      attr_tokens :sympathy

      def faction_symbol
        :mice
      end

      def handle_faction_token_setup
        @meeples = Array.new(10) { Pieces::Meeple.new(:mice) }
        @tokens = Array.new(10) { Mice::Sympathy.new }
        @supporters = []
        @officers = []
        handle_base_building
      end

      def board_title(show_private)
        supporters_text = show_private ? '' : "#{supporters.count} Supporters | "
        "Outrage | Guerilla Warfare | Martial Law\n#{supporters_text}#{officers.count} Officers | #{item_list_for_info}"
      end

      def special_info(show_private)
        {
          board: {
            title: board_title(show_private),
            rows: board_special_info(show_private)
          }
        }
      end

      VICTORY_POINTS = {
        sympathy: [0, 1, 1, 1, 2, 2, 3, 4, 4, 4]
      }.freeze

      def sympathy_tracker_info(show_private)
        cur = VICTORY_POINTS[:sympathy][0...current_number_out(:sympathy)]
        symp = cur.fill('S', cur.length, BUILDINGS - cur.length)
        [
          'Sympathy',
          "(1) #{symp[0]} #{symp[1]} #{symp[2]}",
          "(2) #{symp[3]} #{symp[4]} #{symp[5]}",
          "(3) #{symp[6]} #{symp[7]} #{symp[8]} #{symp[9]}"
        ].tap { |arr| arr << ' ' if show_private }
      end

      def formatted_bases(show_private)
        [
          'Bases',
          display_for_base(:fox),
          display_for_base(:bunny),
          display_for_base(:mouse)
        ].tap { |arr| arr << ' ' if show_private }
      end

      def display_for_base(suit)
        bases.map(&:suit).include?(suit) ? suit.to_s.capitalize : '(+1)'
      end

      def supporters_for(suit)
        supporters.select { |s| s.suit == suit }
      end

      def formatted_supporters
        [
          'Supporters',
          "Fox: #{supporters_for(:fox).count}",
          "Bunny: #{supporters_for(:bunny).count}",
          "Mouse: #{supporters_for(:mouse).count}",
          "Bird: #{supporters_for(:bird).count}"
        ]
      end

      def board_special_info(show_private)
        rows = []
        rows << formatted_supporters if show_private
        rows << formatted_bases(show_private)
        rows << sympathy_tracker_info(show_private)
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

      def pre_move(move_action)
        return if move_action.faction.faction_symbol == faction_symbol
        return unless move_action.to_clearing.sympathetic?

        outrage(move_action.faction, move_action.to_clearing.suit)
      end

      # If Sympathy removed
      # If Base removed
      # Easy hook for bases later
      def post_battle(battle)
        if battle.pieces_removed.map(&:type).include?(:sympathy)
          outrage(battle.other_faction(self), battle.clearing.suit)
        end
      end

      def outrage(other_faction, suit)
        card_opts = other_faction.cards_in_hand_with_suit(suit)
        return draw_to_supporters if card_opts.empty?

        choice = other_faction.player.pick_option(:m_outrage_card, card_opts)
        card = card_opts[choice]
        other_faction.hand.delete(card)
        supporters << card
      end

      def take_turn(players:, **_)
        birdsong
        daylight
        evening(players)
      end

      def birdsong
        revolt
        spread_sympathy
      end

      def revolt; end

      def spread_sympathy; end

      def daylight; end

      def evening(players); end
    end
  end
end
