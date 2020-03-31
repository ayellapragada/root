# frozen_string_literal: true

module Root
  module Factions
    # Handle cats faction logic
    class Cat < Base
      SETUP_PRIORITY = 'A'

      attr_reader :remaining_actions

      def faction_symbol
        :cats
      end

      def handle_faction_token_setup
        handle_meeple_setup
        handle_building_setup
        handle_token_setup
        @remaining_actions = 0
      end

      def handle_meeple_setup
        @meeples = Array.new(25) { Pieces::Meeple.new(:cat) }
      end

      def handle_building_setup
        @buildings = [
          Array.new(6) { Cats::Recruiter.new },
          Array.new(6) { Cats::Sawmill.new },
          Array.new(6) { Cats::Workshop.new }
        ].flatten
      end

      def handle_token_setup
        @tokens = [Cats::Keep.new] + Array.new(8) { Cats::Wood.new }
      end

      def recruiters
        buildings.select { |b| b.type == :recruiter }
      end

      def sawmills
        buildings.select { |b| b.type == :sawmill }
      end

      def workshops
        buildings.select { |b| b.type == :workshop }
      end

      def wood
        tokens.select { |b| b.type == :wood }
      end

      def keep
        tokens.select { |b| b.type == :keep }
      end

      def setup(*)
        build_keep
        build_initial_buildings
        place_initial_warriors
      end

      def build_keep
        options = board.available_corners
        choice = player.pick_option(:c_initial_keep, options)
        clearing = options[choice]

        piece = tokens.delete(keep.pop)
        board.place_token(piece, clearing)
      end

      def build_initial_buildings
        [sawmills, recruiters, workshops].each do |buils|
          building = buils.first
          buildings.delete(building)
          player_places_building(building)
        end
      end

      def player_places_building(building)
        options_for_building = find_initial_options
        key = "c_initial_#{building.type}".to_sym
        choice = player.pick_option(key, options_for_building)
        clearing = options_for_building[choice]
        board.create_building(building, clearing)
      end

      def find_initial_options
        keep_clearing = board.corner_with_keep
        [keep_clearing, *keep_clearing.adjacents].select(&:with_spaces?)
      end

      def place_initial_warriors
        clearing = board.clearing_across_from_keep
        board.clearings_other_than(clearing).each do |cl|
          board.place_meeple(meeples.pop, cl)
        end
      end

      def take_turn( deck:, **_)
        @recruited = false
        birdsong
        daylight(deck)
        evening(deck)
      end

      def birdsong
        board.clearings_with(:sawmill).each do |sawmill_clearing|
          piece = wood.first
          board.place_token(piece, sawmill_clearing)
          tokens.delete(piece)
        end
      end

      def recruit
        @recruited = true
        board.clearings_with(:recruiter).each do |clearing|
          board.place_meeple(meeples.pop, clearing)
        end
      end

      def currently_available_options
        %i[battle march build overwork].tap do |options|
          options << :discard_bird if hand.any? { |card| card.suit == :bird }
          options << :recruit unless @recruited
        end
      end

      def discard_bird(deck)
        options = hand.select { |card| card.suit == :bird }
        choice = player.pick_option(:c_discard_bird, options)
        card = options[choice]
        deck.discard_card(card)
        hand.delete(card)
        @remaining_actions += 1
      end

      def daylight(deck)
        craft_items(deck)
        @remaining_actions = 3
      end

      def craft_items(deck)
        @crafted_suits = []
        until craftable_items.empty?
          options = craftable_items
          choice = player.pick_option(:f_item_select, options)
          item = options[choice]
          craft_item(item, deck)
        end
      end

      def craft_item(choice, deck)
        @crafted_suits.concat(choice.craft)
        board.items.delete(choice.item)
        deck.discard_card(choice)
        hand.delete(choice)
        self.victory_points += choice.vp
        items << choice.item
      end

      def craftable_items
        @crafted_suits ||= []
        suits = board.clearings_with(:workshop).map(&:suit)
        usable_suits = suits - @crafted_suits
        return unless usable_suits
        hand.select do |card|
          card.craftable? &&
            (card.craft - usable_suits).empty? &&
            board.items.include?(card.item)
        end
      end

      def evening(deck)
        draw_card(deck)
      end
    end
  end
end
