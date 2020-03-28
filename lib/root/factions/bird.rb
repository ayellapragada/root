# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle birds faction logic
    class Bird < Base
      SETUP_PRIORITY = 'B'

      attr_reader :viziers, :leaders, :used_leaders, :current_leader, :decree

      def faction_symbol
        :birds
      end

      def handle_faction_token_setup
        @meeples = Array.new(20) { Pieces::Meeple.new(:bird) }
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

      def roosts
        buildings.select { |b| b.type == :roost }
      end

      def setup(board:, **_)
        setup_roost_in_corner(board)
        change_current_leader
        change_viziers_with_leader
      end

      def setup_roost_in_corner(board)
        if board.keep_in_corner?
          clearing = board.clearing_across_from_keep
        else
          options = board.available_corners
          choice = player.pick_option(options)
          clearing = options[choice]
        end
        piece = buildings.delete(roosts.pop)
        board.create_building(piece, clearing)
        6.times { board.place_meeple(meeples.pop, clearing) }
      end

      def change_current_leader(type = nil)
        used_leaders << current_leader if current_leader
        if used_leaders.count >= 4
          self.leaders = used_leaders
          self.used_leaders = []
        end

        if type
          new_leader = leaders.find { |l| l.leader == type }
          leaders.delete(new_leader)
        else
          options = leaders
          choice = player.pick_option(options)
          new_leader = leaders.delete(options[choice])
        end
        self.current_leader = new_leader
      end

      def change_viziers_with_leader
        current_leader.decree.each do |action|
          decree[action] << viziers.pop.suit
        end
      end

      private

      attr_writer :current_leader, :leaders, :used_leaders
    end
  end
end
