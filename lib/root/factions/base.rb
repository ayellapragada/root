# frozen_string_literal: true

require_relative '../core_extensions/symbol/pluralize'

module Root
  module Factions
    # Interface for basic faction logic
    class Base
      Symbol.include CoreExtensions::Symbol::Pluralize

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

      attr_accessor :victory_points

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

      def place_meeple(clearing)
        board.place_meeple(meeples.pop, clearing)
      end

      def craft_items
        @crafted_suits = []
        until craftable_items.empty?
          options = craftable_items
          choice = player.pick_option(:f_item_select, options)
          item = options[choice]
          craft_item(item)
        end
      end

      def craft_item(choice)
        @crafted_suits.concat(choice.craft)
        board.items.delete(choice.item)
        deck.discard_card(choice)
        hand.delete(choice)
        self.victory_points += choice.vp
        items << choice.item
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

      def move(clearing)
        where_to_opts = clearing_move_options(clearing)
        where_to_choice = player.pick_option(:f_move_to_options, where_to_opts)
        where_to = where_to_opts[where_to_choice]

        max_choice = clearing.meeples_of_type(faction_symbol).count
        how_many_opts = [*1.upto(max_choice)]
        how_many_choice = player.pick_option(:f_move_number, how_many_opts)
        how_many = how_many_opts[how_many_choice]

        how_many.times do
          piece = clearing.meeples_of_type(faction_symbol).first
          clearing.meeples.delete(piece)
          where_to.meeples << piece
        end

        player.add_to_history(
          :f_move_number,
          num: how_many,
          from: clearing.priority,
          to: where_to.priority
        )
      end

      def battle_options(suits = [])
        clearings = board.clearings_with_meeples(faction_symbol)

        clearings.select! { |cl| suits.include? cl.suit } unless suits.empty?

        clearings.select do |clearing|
          clearing.includes_any_other_attackable_faction?(faction_symbol)
        end
      end

      def battle(players)
        opts = battle_options
        choice = player.pick_option(:f_battle_options, opts)
        clearing = opts[choice]
        battle_in_clearing(clearing, players)
      end

      def battle_in_clearing(clearing, players)
        opts = clearing.other_attackable_factions(faction_symbol)
        choice = player.pick_option(:f_who_to_battle, opts)
        faction_to_battle = opts[choice]
        faction = players.fetch_player(faction_to_battle).faction

        initiate_battle_with_faction(clearing, faction)
      end

      def initiate_battle_with_faction(clearing, faction)
        attacker_roll, defender_roll = [dice_roll, dice_roll].sort.reverse
        attacker_meeples = clearing.meeples_of_type(faction_symbol)
        defender_meeples = clearing.meeples_of_type(faction.faction_symbol)

        actual_attack = [attacker_roll, attacker_meeples.count].min
        actual_defend = [defender_roll, defender_meeples.count].min

        actual_attack += 1 if defender_meeples.empty?

        deal_damage(actual_defend, self, clearing, faction)
        deal_damage(actual_attack, faction, clearing, self)
        player.add_to_history(
          :f_who_to_battle,
          damage_done: actual_attack,
          damage_taken: actual_defend,
          other_faction: faction.faction_symbol
        )
      end

      def deal_damage(number, faction, clearing, other_faction)
        until number.zero?
          meeples = clearing.meeples_of_type(faction.faction_symbol)
          cardboard_pieces =
            (clearing.buildings_of_faction(faction.faction_symbol) +
             clearing.tokens_of_faction(faction.faction_symbol))
          if !meeples.empty?
            piece = meeples.first
            clearing.meeples.delete(piece)
            faction.meeples << piece
          elsif !cardboard_pieces.empty?
            opts = cardboard_pieces
            choice = player.pick_option(:f_remove_piece, opts)
            piece = opts[choice]
            plural_form = piece.piece_type.pluralize
            faction.send(plural_form) << piece
            clearing.send(plural_form).delete(piece)
            other_faction.victory_points += 1
          end
          number -= 1
        end
      end

      def dice_roll
        [0, 1, 2, 3].sample
      end

      def clearings_ruled_with_space
        board
          .clearings_with_rule(faction_symbol)
          .select(&:with_spaces?)
      end

      def discard_card_with_suit(suit)
        options = cards_in_hand_with_suit(suit)
        choice = player.pick_option(:f_discard_card, options)
        card = options[choice]
        discard_card(card)
        player.add_to_history(:f_discard_card, suit: card.suit)
      end

      def draw_cards
        num = 1 + draw_bonuses
        num.times { draw_card }
        player.add_to_history(:f_draw_cards, num: num)
        discard_card_with_suit(nil) until hand_size <= 5
      end
    end
  end
end
