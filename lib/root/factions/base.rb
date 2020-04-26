# frozen_string_literal: true

require_relative '../core_extensions/symbol/pluralize'
require_relative '../core_extensions/array/delete_first'

module Root
  module Factions
    # Interface for basic faction logic
    class Base
      Symbol.include CoreExtensions::Symbol::Pluralize
      Array.include CoreExtensions::Array::DeleteFirst

      SETUP_PRIORITY = 'ZZZ'

      HISTORY_EXCLUSION = %i[wood].freeze

      def self.attr_buildings(*names)
        names.each { |name| define_methods(:buildings, name) }
      end

      def self.attr_tokens(*names)
        names.each { |name| define_methods(:tokens, name) }
      end

      # Defines the plural accessor, i.e.
      # sawmills, wood, roosts
      # and the place_TOKEN(clearing) method
      # place_keep, place_wood
      def self.define_methods(type, name)
        plural_name = name.pluralize

        define_method(plural_name) { send(type).select { |b| b.type == name } }
        define_method("place_#{name}") do |clearing|
          piece = send(plural_name).first

          if type == :tokens
            board.place_token(piece, clearing)
          else
            board.create_building(piece, clearing)
          end
          send(type).delete(piece)

          return if HISTORY_EXCLUSION.include?(piece.type)

          player.add_to_history(
            :f_build_options,
            type: piece.type,
            clearing: clearing.priority
          )
        end
      end

      attr_reader :victory_points

      attr_reader :hand, :player, :meeples, :buildings, :tokens, :items
      attr_writer :board

      def initialize(player)
        @player = player
        @hand = []
        @victory_points = 0
        set_base_pieces
        handle_faction_token_setup
      end

      def board
        player.board
      end

      def deck
        player.deck
      end

      def victory_points=(value)
        @victory_points = value
        return if @victory_points < 30

        raise Errors::WinConditionReached.new(self, :vps)
      end

      def set_base_pieces
        @meeples = []
        @buildings = []
        @tokens = []
        @items = []
      end

      def hand_size
        hand.size
      end

      def discard_hand
        @hand = []
      end

      def draw_card
        @hand.concat(deck.draw_from_top)
      end

      def discard_card(card)
        deck.discard_card(card)
        hand.delete(card)
      end

      def setup_priority
        self.class::SETUP_PRIORITY
      end

      def take_turn(players:, active_quests: nil); end

      def special_info(_show_private)
        []
      end

      def item_list_for_info
        items.empty? ? 'No items' : items.map(&:capitalize).join(', ')
      end

      def formatted_special_info(show_private)
        special_info(show_private).map do |_key, val|
          opts = {}.tap do |obj|
            obj[:rows] = val[:rows]
            obj[:headings] = val[:headings] if val[:headings]
            obj[:title] = val[:title] if val[:title]
            # Currently unused
            # obj[:style] = val[:style] if val[:style]
          end
          Terminal::Table.new(opts)
        end
      end

      def current_number_out(type)
        self.class::BUILDINGS - send(type.pluralize).count
      end

      def format_with_victory_ponts_and_draw_bonuses(type)
        current_points = self.class::VICTORY_POINTS[type][0...current_number_out(type)]
        bonuses = self.class::DRAW_BONUSES[type][0...current_number_out(type)]
        piece_symbol = send(type.pluralize).first&.display_symbol
        res = current_points.map.with_index do |val, idx|
          bonuses[idx].zero? ? val.to_s : "#{val}(+#{bonuses[idx]})"
        end
        [type.pluralize.to_s.capitalize] +
          res.fill(piece_symbol, res.length, self.class::BUILDINGS - res.length)
      end

      def place_meeple(clearing)
        board.place_meeple(meeples.pop, clearing)
      end

      def craft_items
        @crafted_suits = []
        until craftable_items.empty?
          options = craftable_items + [:none]
          choice = player.pick_option(:f_item_select, options)
          item = options[choice]
          return if item == :none

          @crafted_suits.concat(item.craft)
          craft_item(item)
        end
      end

      def craft_item(choice)
        board.items.delete_at(board.items.index(choice.item))
        deck.discard_card(choice)
        hand.delete(choice)
        self.victory_points += handle_item_vp(choice)
        items << choice.item
        player.add_to_history(:f_item_select, item: choice.item, vp: choice.vp)
      end

      def handle_item_vp(item)
        item.vp
      end

      def craftable_items
        @crafted_suits ||= []
        usable_suits = suits_to_craft_with - @crafted_suits
        return [] if usable_suits.empty?

        craftable_cards_in_hand(usable_suits)
      end

      def craftable_cards_in_hand(suits)
        hand.select do |card|
          card.craftable? &&
            (card.craft - suits).empty? &&
            board.items.include?(card.item)
        end
      end

      def make_move(players)
        player.choose(:f_move_from_options, move_options) do |clearing|
          move(clearing, players)
        end
      end

      def move_options(suits = [])
        possible_options = []
        clearings = board.clearings_with_meeples(faction_symbol)

        clearings.select! { |cl| suits.include? cl.suit } unless suits.empty?

        clearings.select do |clearing|
          clearing.adjacents.each do |adj|
            next if possible_options.include?(clearing)

            possible_options << clearing if rule?(clearing) || rule?(adj)
          end
        end

        possible_options
      end

      def clearing_move_options(clearing)
        clearing.adjacents.select do |adj|
          rule?(clearing) || rule?(adj)
        end
      end

      def rule?(clearing)
        clearing.ruled_by == faction_symbol
      end

      def can_move?
        !move_options.empty?
      end

      def move(clearing, players)
        where_to_opts = clearing_move_options(clearing)
        where_to_choice = player.pick_option(:f_move_to_options, where_to_opts)
        where_to = where_to_opts[where_to_choice]

        max_choice = clearing.meeples_of_type(faction_symbol).count
        how_many_opts = [*1.upto(max_choice)]
        how_many_choice = player.pick_option(:f_move_number, how_many_opts)
        how_many = how_many_opts[how_many_choice]

        Actions::Move.new(clearing, where_to, how_many, self, players).()
      end

      def can_battle?
        !battle_options.empty?
      end

      def battle_options(suits = [])
        clearings = board.clearings_with_meeples(faction_symbol)

        clearings.select! { |cl| suits.include? cl.suit } unless suits.empty?

        clearings.select do |clearing|
          clearing.includes_any_other_attackable_faction?(faction_symbol)
        end
      end

      def battle(players)
        player.choose(:f_battle_options, battle_options) do |clearing|
          battle_in_clearing(clearing, players)
        end
      end

      def battle_in_clearing(clearing, players)
        opts = clearing.other_attackable_factions(faction_symbol)
        choice = player.pick_option(:f_who_to_battle, opts)
        faction_to_battle = opts[choice]
        faction = players.fetch_player(faction_to_battle).faction

        initiate_battle_with_faction(clearing, faction)
      end

      def initiate_battle_with_faction(clearing, other_faction)
        Actions::Battle.new(clearing, self, other_faction).()
      end

      def clearings_ruled_with_space
        board
          .clearings_with_rule(faction_symbol)
          .select(&:with_spaces?)
      end

      def convert_needed_suits(suits)
        suits.include?(:bird) ? %i[fox mouse bunny] : suits
      end

      def cards_in_hand_with_suit(suit = nil, bird: true)
        return hand unless suit

        hand.select do |card|
          card.suit == suit || (bird && card.suit == :bird)
        end
      end

      def discard_card_with_suit(suit, bird: true)
        options = cards_in_hand_with_suit(suit, bird: bird)
        player.choose(:f_discard_card, options, required: true) do |card|
          discard_card(card)
          player.add_to_history(:f_discard_card, suit: card.suit)
        end
      end

      def draw_cards
        num = 1 + draw_bonuses
        num.times { draw_card }
        player.add_to_history(:f_draw_cards, num: num)
        discard_card_with_suit(nil) until hand_size <= 5
      end

      def place_building(building, clearing)
        buildings.delete(building)
        board.create_building(building, clearing)
        player.add_to_history(
          :f_build_options,
          type: building.type,
          clearing: clearing.priority
        )
      end

      def prompt_for_action(key)
        opts = %w[Yes No]
        choice = player.pick_option(key, opts)
        choice.zero?
      end

      def with_action
        @remaining_actions -= 1
        yield
      end

      def pre_move(move_action); end

      def pre_battle(battle); end

      def post_battle(battle); end
    end
  end
end
