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

      BUILDINGS = 3
      TOKENS = 10

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

      DRAW_BONUSES = {
        bases: [1, 1, 1]
      }.freeze

      VICTORY_POINTS = {
        sympathy: [0, 1, 1, 1, 2, 2, 3, 4, 4, 4]
      }.freeze

      COSTS = {
        sympathy: [1, 1, 1, 2, 2, 2, 3, 3, 3, 3]
      }.freeze

      def current_number_out(type)
        if type == :bases
          BUILDINGS - bases.count
        else
          TOKENS - sympathy.count
        end
      end

      def sympathy_tracker_info(show_private)
        cur = VICTORY_POINTS[:sympathy][0...current_number_out(:sympathy)]
        symp = cur.fill('S', cur.length, TOKENS - cur.length)
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
        add_to_supporters(deck.draw_from_top(num))
      end

      def add_to_supporters(supporters)
        @supporters.concat(supporters)
      end

      def supporters_for(suit)
        supporters.select { |s| s.suit == suit }
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
        birdsong(players)
        daylight
        evening(players)
      end

      def birdsong(players)
        revolt(players)
        spread_sympathy
      end

      def revolt(players)
        until revolt_options.empty?
          return unless prompt_for_action(:m_revolt_check)

          opts = revolt_options
          choice = player.pick_option(:m_revolt, opts)
          clearing = opts[choice]

          remove_supporters(2, clearing.suit)
          revolt_in_clearing(clearing, players)
        end
      end

      def remove_supporters(num, suit)
        num.times { remove_supporter(suit) }
      end

      def remove_supporter(suit)
        opts = usable_supporters(suit)
        choice = player.pick_option(:m_supporter_to_use, opts)
        supporter = opts[choice]
        deck.discard_card(supporter)
        supporters.delete(supporter)
      end

      def revolt_in_clearing(clearing, players)
        pieces = clearing.all_other_pieces(faction_symbol)
        pieces.each do |piece|
          type = piece.piece_type
          plural_form = type.pluralize
          other_faction = players.fetch_player(piece.faction).faction
          other_faction.send(plural_form) << piece
          clearing.send(plural_form).delete(piece)
          self.victory_points += 1 if %i[building token].include?(type)
        end
        board
          .clearings_with(:sympathy)
          .count { |cl| cl.suit == clearing.suit }
          .times { place_meeple(clearing) }
        place_base(clearing.suit, clearing)
      end

      def revolt_options
        unbuilt_base_suits = bases.map(&:suit)
        board
          .clearings_with(:sympathy)
          .select { |c| unbuilt_base_suits.include?(c.suit) }
          .select { |c| usable_supporters(c.suit).count >= 2 }
      end

      def built_base_suits
        unbuilt_base_suits = bases.map(&:suit)
        %i[fox bunny mouse] - unbuilt_base_suits
      end

      def usable_supporters(suit)
        supporters_for(suit) + supporters_for(:bird)
      end

      def spread_sympathy
        until spread_sympathy_options.empty?
          return unless prompt_for_action(:m_spread_sympathy_check)

          opts = spread_sympathy_options
          choice = player.pick_option(:m_spread_sympathy, opts)
          clearing = opts[choice]

          remove_supporters(total_supporter_cost(clearing), clearing.suit)
          spread_sympathy_in_clearing(clearing)
        end
      end

      def spread_sympathy_in_clearing(clearing)
        place_sympathy(clearing)
        vps = VICTORY_POINTS[:sympathy][current_number_out(:sympathy) - 1]
        self.victory_points += vps
      end

      def spread_sympathy_options
        sympathetic = board.clearings_with(:sympathy)
        if sympathetic.empty?
          return board.clearings_without_keep.select { |cl| enough_supporters?(cl) }
        end

        total_opts = []

        sympathetic.each do |clearing|
          clearing.adjacents.each do |adj|
            next if adj.sympathetic? || total_opts.include?(adj) || adj.keep?

            total_opts << adj if enough_supporters?(adj)
          end
        end

        total_opts
      end

      def enough_supporters?(clearing)
        usable_supporters(clearing.suit).count >= total_supporter_cost(clearing)
      end

      def total_supporter_cost(clearing)
        extra_cost = martial_law_applied?(clearing) ? 1 : 0
        cost_for_next_sympathy + extra_cost
      end

      def martial_law_applied?(clearing)
        clearing.other_attackable_factions(faction_symbol).any? do |fac|
          clearing.meeples_of_type(fac).count >= 3
        end
      end

      def cost_for_next_sympathy
        COSTS[:sympathy][10 - sympathy.length]
      end

      def daylight
        until currently_available_options.empty?
          opts = currently_available_options + [:none]
          choice = player.pick_option(:f_pick_action, opts)
          action = opts[choice]

          # :nocov:
          case action
          when :craft then craft_items
          when :mobilize then mobilize
          when :train then train
          when :none then return
          end
          # :nocov:
        end
      end

      def currently_available_options
        [].tap do |options|
          options << :craft if can_craft?
          options << :mobilize if can_mobilize?
          options << :train if can_train?
        end
      end

      def can_craft?
        !craftable_items.empty?
      end

      def can_mobilize?
        !hand.empty?
      end

      def can_train?
        !train_options.empty? && !meeples.count.zero?
      end

      def train_options
        hand.select do |card|
          built_base_suits.include?(card.suit) || card.suit == :bird
        end
      end

      def mobilize
        opts = hand
        choice = player.pick_option(:m_mobilize, opts)
        card = opts[choice]
        add_to_supporters([card])
        hand.delete(card)
      end

      def train
        opts = train_options
        choice = player.pick_option(:m_train, opts)
        card = opts[choice]
        discard_card(card)
        officers << meeples.pop
      end

      def suits_to_craft_with
        board.clearings_with(:sympathy).map(&:suit)
      end

      def evening(_players)
        # military_operations
        draw_cards
      end

      def draw_bonuses
        DRAW_BONUSES[:bases][0...current_number_out(:bases)].sum
      end
    end
  end
end
