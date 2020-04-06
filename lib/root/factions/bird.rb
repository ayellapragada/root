# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle birds faction logic
    class Bird < Base
      SETUP_PRIORITY = 'B'

      attr_reader :viziers, :leaders, :used_leaders, :current_leader, :decree

      attr_buildings :roost

      def faction_symbol
        :birds
      end

      def handle_faction_token_setup
        @meeples = Array.new(20) { Pieces::Meeple.new(:birds) }
        @buildings = Array.new(7) { Birds::Roost.new }
        @viziers = Array.new(2) { Cards::Base.new(suit: :bird) }
        handle_leader_setup
      end

      def handle_leader_setup
        @leaders = Birds::Leader.generate_initial
        @used_leaders = []
        @current_leader = nil
        reset_decree
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
      end

      def reset_leaders
        self.leaders = used_leaders
        self.used_leaders = []
      end

      def find_next_leader(type)
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
      end

      def birdsong
        @bird_added = false
        draw_card(deck) if hand.empty?
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

      def daylight(_players)
        craft_items
      end

      private

      def suits_to_craft_with
        board.clearings_with(:roost).map(&:suit)
      end

      attr_writer :current_leader, :leaders, :used_leaders
    end
  end
end
