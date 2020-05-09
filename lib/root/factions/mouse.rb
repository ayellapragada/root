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
        @remaining_actions = 0
        handle_base_building
      end

      def board_title(show_private)
        supporters_text = show_private ? '' : "#{supporters.count} Supporters | "
        "Outrage | Guerilla Warfare | Martial Law\n#{supporters_text}#{officers.count} Officers \n#{item_list_for_info}"
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

      def sympathy_tracker_info
        cur = VICTORY_POINTS[:sympathy][0...current_number_out(:sympathy)]
        symp = cur.fill('S', cur.length, TOKENS - cur.length)
        [
          'Sympathy',
          "(1) #{symp[0]} #{symp[1]} #{symp[2]}",
          "(2) #{symp[3]} #{symp[4]} #{symp[5]}",
          "(3) #{symp[6]} #{symp[7]} #{symp[8]} #{symp[9]}"
        ]
      end

      def formatted_bases
        [
          'Bases',
          display_for_base(:fox),
          display_for_base(:rabbit),
          display_for_base(:mouse)
        ]
      end

      def display_for_base(suit)
        bases.map(&:suit).include?(suit) ? suit.to_s.capitalize : '(+1)'
      end

      def formatted_supporters
        [
          "Bird (#{supporters_for(:bird).count})",
          "Fox (#{supporters_for(:fox).count})",
          "Rabbit (#{supporters_for(:rabbit).count})",
          "Mouse (#{supporters_for(:mouse).count})"
        ]
      end

      def board_special_info(show_private)
        rows = []
        rows << formatted_supporters if show_private
        rows << formatted_bases
        rows << sympathy_tracker_info
        rows
      end

      def handle_base_building
        @buildings = [
          Mice::Base.new(:fox),
          Mice::Base.new(:rabbit),
          Mice::Base.new(:mouse)
        ]
      end

      def setup(**_)
        draw_to_supporters(3)
      end

      def draw_to_supporters(num = 1)
        add_to_supporters(deck.draw_from_top(num))
      end

      def add_to_supporters(cards)
        cards.each do |card|
          if bases.count == 3 && supporters.count >= 5
            deck.discard_card(card)
          else
            @supporters.concat([card])
          end
        end
      end

      def supporters_for(suit)
        supporters.select { |s| s.suit == suit }
      end

      # Overwrites the attr_buildings
      def place_base(clearing)
        base = bases.find { |b| b.suit == clearing.suit }
        place_building(base, clearing)
      end

      def pre_move(move_action)
        return if skip_outrage_for?(move_action.faction.faction_symbol)
        return unless move_action.to_clearing.sympathetic?

        outrage(move_action.actual_leader, move_action.to_clearing.suit)
      end

      # racoons are not pawns ayyy and outrage only affects pawns
      def skip_outrage_for?(symbol)
        [:racoon, faction_symbol].include?(symbol)
      end

      def post_battle(battle)
        suit = battle.clearing.suit

        outrage(battle.other_faction(self), suit) if battle.removed?(:sympathy)
        base_removed(suit) if battle.removed?(:base)
      end

      def base_removed(suit)
        usable_supporters(suit).each do |card|
          discard_card(card)
          supporters.delete(card)
        end

        discard_down_to_five_supporters
        lose_half_officers
      end

      def discard_down_to_five_supporters
        remove_supporter until supporters.count <= 5
      end

      def lose_half_officers
        num_officers_to_lose = (officers.count / 2.0).ceil
        num_officers_to_lose.times { meeples << officers.pop }
      end

      def outrage(other_faction, suit)
        card_opts = other_faction.cards_in_hand_with_suit(suit)
        return draw_to_supporters if card_opts.empty?

        other_faction.player.choose(:m_outrage_card, card_opts, required: true) do |card|
          other_faction.hand.delete(card)
          supporters << card
        end
      end

      def take_turn(players:, **_)
        super
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
          player.choose(:m_revolt, revolt_options, yield_anyway: true) do |cl|
            return false if cl == :none

            remove_supporters(2, cl.suit)
            revolt_in_clearing(cl, players)
          end
        end
      end

      def remove_supporters(num, suit)
        num.times { remove_supporter(suit) }
      end

      def remove_supporter(suit = nil)
        player.choose(
          :m_supporter_to_use,
          usable_supporters(suit),
          required: true
        ) do |supporter|
          deck.discard_card(supporter)
          supporters.delete(supporter)
        end
      end

      def revolt_in_clearing(clearing, players)
        do_big_damage(clearing, players)
        board
          .clearings_with(:sympathy)
          .count { |cl| cl.suit == clearing.suit }
          .times { place_meeple(clearing) }
        promote_officer
        place_base(clearing)
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
        %i[fox rabbit mouse] - unbuilt_base_suits
      end

      def usable_supporters(suit)
        return supporters unless suit

        supporters_for(suit) + supporters_for(:bird)
      end

      def spread_sympathy
        until spread_sympathy_options.empty? || sympathy.count.zero?
          opts = spread_sympathy_options
          player.choose(:m_spread_sympathy, opts, yield_anyway: true) do |cl|
            return false if cl == :none

            remove_supporters(total_supporter_cost(cl), cl.suit)
            spread_sympathy_in_clearing(cl)
          end
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
        until daylight_options.empty?
          player.choose(
            :f_pick_action,
            daylight_options,
            yield_anyway: true,
            info: { actions: '' }
          ) do |action|
            # :nocov:
            case action
            when :craft then craft_items
            when :mobilize then mobilize
            when :train then train
            when :none then return false
            end
            # :nocov:
          end
        end
      end

      def daylight_options
        [].tap do |options|
          options << :craft if can_craft?
          options << :mobilize if can_mobilize?
          options << :train if can_train?
        end
      end

      def can_mobilize?
        !hand.empty?
      end

      def can_train?
        !train_options.empty? && !meeples.count.zero?
      end

      # Maybe there's a better way for this.
      # There needs to be something like hand.matches_suit?(suit)
      def train_options
        return [] if built_base_suits.empty?

        hand.select do |card|
          built_base_suits.include?(card.suit) || card.suit == :bird
        end
      end

      def mobilize
        do_until_stopped(:m_mobilize, proc { hand }) do |card|
          add_to_supporters([card])
          hand.delete(card)
        end
      end

      def train
        do_until_stopped(:m_train, proc { train_options }) do |card|
          promote_officer
          discard_card(card)
        end
      end

      def promote_officer
        officers << meeples.pop if meeples.count.positive?
      end

      def suits_to_craft_with
        board.clearings_with(:sympathy).map(&:suit)
      end

      def evening(players)
        military_operations(players)
        draw_cards
      end

      def military_operations(players)
        @remaining_actions = officers.count

        until evening_options.empty? || @remaining_actions.zero?
          player.choose(
            :f_pick_action,
            evening_options,
            yield_anyway: true,
            info: { actions: "(#{@remaining_actions} actions remaining) " }
          ) do |action|
            # :nocov:
            case action
            when :move then with_action { make_move(players) }
            when :recruit then with_action { recruit }
            when :battle then with_action { battle(players) }
            when :organize then with_action { organize }
            when :none then @remaining_actions = 0
            end
            # :nocov:
          end
        end
      end

      def evening_options
        [].tap do |options|
          options << :move if can_move?
          options << :recruit if can_recruit?
          options << :battle if can_battle?
          options << :organize if can_organize?
        end
      end

      def can_recruit?
        !recruit_options.empty? && !meeples.count.zero?
      end

      def recruit_options
        board.clearings_with(:base)
      end

      def recruit
        player.choose(:f_recruit_clearing, recruit_options) do |cl|
          player.add_to_history(:f_recruit_clearing, clearing: cl.priority)
          place_meeple(cl)
        end
      end

      def can_organize?
        !organize_options.empty?
      end

      def organize_options
        board.clearings_with_meeples(:mice).reject(&:sympathetic?)
      end

      def organize
        player.choose(:m_organize_clearing, organize_options) do |clearing|
          meeple = clearing.meeples_of_type(:mice).first
          meeples << meeple
          clearing.meeples.delete(meeple)
          spread_sympathy_in_clearing(clearing)
        end
      end

      def draw_bonuses
        DRAW_BONUSES[:bases][0...current_number_out(:bases)].sum
      end
    end
  end
end
