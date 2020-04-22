# frozen_string_literal: true

require_relative './base'
require_relative '../factions/birds/birdable'
require_relative '../factions/birds/leader'
require_relative '../factions/birds/vizier'

module Root
  module Factions
    class TurmoilError < StandardError; end

    # Handle birds faction logic
    class Bird < Base
      include Factions::Birds::Birdable

      BUILDINGS = 7
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
        @viziers = Array.new(2) { Birds::Vizier.new }
      end

      def reset_decree
        @decree = Birds::Decree.new
      end

      def board_title
        "Lords of the Forest | Disdain for Trade \n#{formatted_leader} | #{item_list_for_info}"
      end

      def special_info(_show_private)
        {
          board: {
            title: board_title,
            rows: board_special_info
          },
          decree: {
            rows: decree.special_info,
            headings: %w[Recruit Move Battle Build]
          }
        }
      end

      def formatted_leader
        return 'No Leader' unless current_leader

        current_leader.leader.capitalize
      end

      def board_special_info
        [format_with_victory_ponts_and_draw_bonuses(:roost)]
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

      # Resolve decree only needs players for battle and move!
      # MOVE IS OUTRAGE :yikes:
      # So we're letting it be nil for test, but this is DEF needed
      def resolve_decree(players = nil)
        resolve_recruit
        resolve_move(players)
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

          num_to_recruit = current_leader?(:charismatic) ? 2 : 1
          raise TurmoilError if meeples.count < num_to_recruit

          num_to_recruit.times { place_meeple(cl) }
          player.add_to_history(:b_recruit_clearing, clearing: cl.priority)
        end
      end

      def resolve_move(players)
        resolve(:move, :f_move_from_options) { |cl| move(cl, players) }
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
          .reject(&:keep?)
          .select { |cl| suits.include?(cl.suit) }
          .select { |cl| cl.buildings_of_type(:roost).empty? }
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
        player.add_to_history(:b_turmoil)
        change_victory_points_for_turmoil
        discard_from_decree
        change_current_leader
        reset_decree
        reset_viziers
        change_viziers_with_leader
      end

      def change_victory_points_for_turmoil
        self.victory_points -= decree.number_of_birds
        self.victory_points = 0 if self.victory_points.negative?
      end

      def discard_from_decree
        all_cards = decree.all_cards_except_viziers
        all_cards.each { |card| discard_card(card) }
      end

      # Disdain for Trade
      def handle_item_vp(item)
        current_leader?(:builder) ? item.vp : 1
      end

      def pre_battle(battle)
        return unless battle.attacker?(self) && current_leader?(:commander)

        battle.actual_attack += 1
      end

      def post_battle(battle)
        return unless current_leader?(:despot)

        self.victory_points += 1 if battle.pieces_removed.any?(&:points_for_removing?)
      end

      def current_leader?(type)
        current_leader&.leader == type
      end

      private

      def suits_to_craft_with
        board.clearings_with(:roost).map(&:suit)
      end

      attr_writer :current_leader, :leaders, :used_leaders
    end
  end
end
