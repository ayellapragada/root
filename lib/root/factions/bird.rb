# frozen_string_literal: true

require_relative './base'
require_relative '../factions/birds/birdable'

module Root
  module Factions
    class TurmoilError < StandardError; end

    # Handle birds faction logic
    class Bird < Base
      include Factions::Birds::Birdable

      SETUP_PRIORITY = 'B'

      attr_reader :viziers, :leaders, :used_leaders, :current_leader, :decree

      attr_buildings :roost

      def faction_symbol
        :birds
      end

      def handle_faction_token_setup
        @meeples = Array.new(20) { Pieces::Meeple.new(:birds) }
        @buildings = Array.new(7) { Birds::Roost.new }
        handle_leader_setup
      end

      def handle_leader_setup
        @leaders = Birds::Leader.generate_initial
        @used_leaders = []
        @current_leader = nil
        reset_viziers
        reset_decree
      end

      def reset_viziers
        @viziers = Array.new(2) { Cards::Vizier.new }
      end

      def reset_decree
        @decree = Birds::Decree.new
      end

      def setup(*)
        setup_roost_in_corner
        change_current_leader
        change_viziers_with_leader
      end

      def setup_roost_in_corner
        clearing = find_clearing_for_first_root
        place_roost(clearing)
        6.times { place_meeple(clearing) }
      end

      def find_clearing_for_first_root
        if board.keep_in_corner?
          board.clearing_across_from_keep
        else
          options = board.available_corners
          choice = player.pick_option(:b_first_roost, options)
          options[choice]
        end
      end

      def change_current_leader(type = nil)
        used_leaders << current_leader if current_leader
        reset_leaders if used_leaders.count >= 4

        new_leader = find_next_leader(type)
        self.current_leader = new_leader
        player.add_to_history(:b_new_leader, leader: new_leader.leader)
      end

      def reset_leaders
        self.leaders = used_leaders
        self.used_leaders = []
      end

      def find_next_leader(type = nil)
        if type
          new_leader = leaders.find { |l| l.leader == type }
          leaders.delete(new_leader)
        else
          options = leaders
          choice = player.pick_option(:b_new_leader, options)
          new_leader = leaders.delete(options[choice])
        end
        new_leader
      end

      def change_viziers_with_leader
        current_leader.decree.each do |action|
          decree[action] << viziers.pop
        end
      end

      def take_turn(players:, **_)
        birdsong
        daylight(players)
        evening
      end

      def birdsong
        @bird_added = false
        draw_card if hand.empty?
        2.times do |i|
          next if hand.empty?
          is_first_time = i.zero?
          card_opts = get_decree_hand_opts(is_first_time)
          card_choice = player.pick_option(:b_card_for_decree, card_opts)
          card = card_opts[card_choice]
          next if card == :none

          @bird_added = true if card.bird?

          decree_opts = decree.choices
          decree_choice = player.pick_option(:b_area_in_decree, decree_opts)
          area = decree_opts[decree_choice]

          decree[area] << card
          hand.delete(card)

          player.add_to_history(
            :b_area_in_decree,
            suit: card.suit,
            area: area
          )
        end

        return unless board.clearings_with(:roost).empty?

        new_base_opts = board.clearings_with_fewest_pieces
        new_base_choice = player.pick_option(:b_comeback_roost, new_base_opts)
        clearing = new_base_opts[new_base_choice]
        place_roost(clearing)
        3.times { place_meeple(clearing) }
      end

      def get_decree_hand_opts(is_first_time)
        opts = @bird_added ? hand.reject(&:bird?) : hand
        is_first_time ? opts : opts + [:none]
      end

      def daylight(players)
        craft_items
        resolve_decree(players)
      end

      VICTORY_POINTS = {
        roost: [0, 1, 2, 3, 4, 4, 5]
      }.freeze

      DRAW_BONUSES = {
        roost: [0, 0, 1, 0, 0, 1, 0]
      }.freeze

      def evening
        vps = VICTORY_POINTS[:roost][current_number_out(:roost) - 1]
        self.victory_points += vps

        draw_cards
      end

      def draw_bonuses
        DRAW_BONUSES[:roost][0...current_number_out(:roost)].sum
      end

      def current_number_out(type)
        7 - send(type.pluralize).count
      end

      # Resolve decree only needs players for battle
      # So we're letting it be nil for test, but this is DEF needed
      def resolve_decree(players = nil)
        resolve_recruit
        resolve_move
        resolve_battle(players)
        resolve_build
      rescue TurmoilError
        turmoil!
      end

      def resolve_recruit
        resolve(:recruit, :b_recruit_clearing) do |cl|
          # So technically this isn't an issue yet.
          # It certainly is a bug, in a few ways, but that's ok.
          # This will get tested with charismatic leader intro.
          # raise TurmoilError if meeples.count.zero?

          place_meeple(cl)
          player.add_to_history(:b_recruit_clearing, clearing: cl.priority)
        end
      end

      def resolve_move
        resolve(:move, :f_move_from_options) { |cl| move(cl) }
      end

      def resolve_battle(players)
        resolve(:battle, :f_battle_options) do |cl|
          battle_in_clearing(cl, players)
        end
      end

      def resolve_build
        resolve(:build, :f_build_options) do |cl|
          raise TurmoilError if roosts.count.zero?

          place_roost(cl)
        end
      end

      def recruit_options(suits)
        board.clearings_with(:roost).select { |cl| suits.include?(cl.suit) }
      end

      def build_options(suits = [])
        clearings_ruled_with_space
          .select { |cl| suits.include?(cl.suit) }
          .select { |cl| cl.buildings_of_type(:roost).empty? }
      end

      def convert_needed_suits(suits)
        suits.include?(:bird) ? %i[fox mouse bunny] : suits
      end

      def resolve(action, key)
        needed_suits = decree.suits_in(action)

        until needed_suits.empty?
          opts = get_options_with_turmoil!(action, needed_suits)
          choice = player.pick_option(key, opts)
          clearing = opts[choice]

          suit = resolve_bird_in_decree(needed_suits, clearing)
          needed_suits.delete_at(needed_suits.index(suit))
          yield(clearing)
        end
      end

      def get_options_with_turmoil!(action, needed_suits)
        option_name = "#{action}_options"
        send(option_name, convert_needed_suits(needed_suits)).tap do |opts|
          raise TurmoilError if opts.empty?
        end
      end

      def resolve_bird_in_decree(needed_suits, clearing)
        needed_suits.include?(clearing.suit) ? clearing.suit : :bird
      end

      def turmoil!
        self.victory_points -= decree.number_of_birds
        player.add_to_history(:b_turmoil)
        discard_from_decree
        change_current_leader
        reset_decree
        reset_viziers
        change_viziers_with_leader
      end

      def discard_from_decree
        all_cards = decree.all_cards_except_viziers
        all_cards.each { |card| discard_card(card) }
      end

      private

      def suits_to_craft_with
        board.clearings_with(:roost).map(&:suit)
      end

      attr_writer :current_leader, :leaders, :used_leaders
    end
  end
end
