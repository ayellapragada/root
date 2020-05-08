# frozen_string_literal: true

require_relative '../core_extensions/symbol/pluralize'
require_relative '../core_extensions/array/better_deletes'

module Root
  module Factions
    # Interface for basic faction logic
    class Base
      Symbol.include CoreExtensions::Symbol::Pluralize
      Array.include CoreExtensions::Array::BetterDeletes

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
          piece
        end
      end

      attr_reader :victory_points

      attr_reader :hand, :player, :meeples, :buildings, :tokens, :items
      attr_writer :board

      def initialize(player)
        @player = player
        @hand = []
        @items = []
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

      def take_turn(players:, quests: nil)
        @crafted_suits = []
      end

      def item_list_for_info
        return 'No Items' if items.empty?

        names = items.map(&:item)
        count = names.tally

        res =
          names
          .uniq
          .map { |item| count[item] > 1 ? "#{item.capitalize} (#{count[item]})" : item.capitalize }
          .join(', ')
        word_wrap_string(res)
      end

      # WOWOWOWOWOW yikers this is a comma based word wrap lets go
      def word_wrap_string(string, el = ', ')
        return string if string.length < 50

        res = [[]]
        counter = 0
        words = string.split(', ')
        words.each do |word|
          if (res[counter] + [word]).join(', ').length < 50
            res[counter] << word
          else
            counter += 1
            res[counter] = [word]
          end
        end

        # add a comma at the end
        res.map.with_index do |arr, idx|
          str = (idx != res.length - 1 ? ',' : '')
          arr.join(', ') + str
        end.join("\n")
      end

      def formatted_special_info(show_private)
        special_info(show_private).map do |_key, val|
          opts = {}.tap do |obj|
            obj[:rows] = val[:rows]
            obj[:headings] = val[:headings] if val[:headings]
            obj[:title] = val[:title] if val[:title]

            style_opts = { width: 54 }
            obj[:style] = style_opts
            obj[:alignment] = :center
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
        board.place_meeple(meeples.pop, clearing) if meeples.count.positive?
      end

      def do_until_stopped(key, options_method)
        loop do
          options = options_method.()
          return if options.empty?

          return false unless player.choose(key, options) do |choice|
            yield(choice)
          end
        end
      end

      def craft_items
        @crafted_suits ||= []
        do_until_stopped(:f_item_select, proc { craftable_items }) do |item|
          @crafted_suits.concat(item.craft)
          yield(item) if block_given?
          craft_item(item)
        end
      end

      def craft_item(choice)
        board.items.delete_first(choice.item)
        deck.discard_card(choice)
        hand.delete(choice)
        self.victory_points += handle_item_vp(choice)
        make_item(choice.item)
        player.add_to_history(:f_item_select, item: choice.item, vp: choice.vp)
      end

      def make_item(type)
        @items << Pieces::Item.new(type)
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
            card.craft.delete_elements_in(suits).empty? &&
            board.items.include?(card.item)
        end
      end

      def can_craft?
        !craftable_items.empty?
      end

      def make_move(players, required: false)
        player.choose(
          :f_move_from_options,
          move_options,
          required: required
        ) do |cl|
          move(cl, players)
        end
      end

      def move_options(suits = [])
        possible_options = []
        clearings = board.clearings_with_meeples(faction_symbol)

        clearings.select! { |cl| suits.include? cl.suit } unless suits.empty?

        clearings.select do |clearing|
          clearing.adjacents.each do |adj|
            next if possible_options.include?(clearing)

            possible_options << clearing if can_move_to?(clearing, adj)
          end
        end

        possible_options
      end

      def can_move_to?(clearing, adj)
        rule?(clearing) || rule?(adj)
      end

      def clearing_move_options(clearing)
        clearing.adjacents.select { |adj| can_move_to?(clearing, adj) }
      end

      def rule?(clearing)
        clearing.ruled_by == faction_symbol
      end

      def can_move?
        !move_options.empty?
      end

      def move(clearing, players)
        opts = clearing_move_options(clearing)

        player.choose(:f_move_to_options, opts) do |where_to|
          max_choice = clearing.meeples_of_type(faction_symbol).count
          how_many_opts = [*1.upto(max_choice)]

          player.choose(:f_move_number, how_many_opts) do |how_many|
            move_meeples(clearing, where_to, how_many, players)
          end
        end
      end

      def move_meeples(from, to, num, players)
        Actions::Move.new(from, to, num, self, players).()
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
        player.choose(:f_battle_options, battle_options) do |cl|
          battle_in_clearing(cl, players)
        end
      end

      def battle_in_clearing(clearing, players)
        opts = clearing.other_attackable_factions(faction_symbol)
        player.choose(:f_who_to_battle, opts) do |fac_sym|
          faction_to_battle = players.fetch_player(fac_sym).faction
          initiate_battle_with_faction(clearing, faction_to_battle)
        end
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
        suits.include?(:bird) ? %i[fox mouse rabbit] : suits
      end

      def cards_in_hand_with_suit(suit = nil)
        return hand unless suit

        hand.select { |card| card.suit == suit || card.suit == :bird }
      end

      def discard_card_with_suit(suit, required: true)
        options = cards_in_hand_with_suit(suit)
        player.choose(:f_discard_card, options, required: required) do |card|
          discard_card(card)
          player.add_to_history(:f_discard_card, suit: card.suit)
          yield if block_given?
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

      def with_action
        @remaining_actions -= 1 if yield
      end

      def max_hit(clearing, *)
        clearing.meeples_of_type(faction_symbol).count
      end

      def defenseless?(clearing)
        max_hit(clearing).zero?
      end

      def take_damage(clearing)
        pieces_removed = []
        meeples = clearing.meeples_of_type(faction_symbol)
        cardboard_pieces =
          (clearing.buildings_of_faction(faction_symbol) +
           clearing.tokens_of_faction(faction_symbol))
        if !meeples.empty?
          piece = meeples.first
          clearing.meeples.delete(piece)
          meeples << piece
          pieces_removed << piece
        elsif !cardboard_pieces.empty?
          player.choose(
            :f_remove_piece,
            cardboard_pieces,
            required: true,
            info: { clearing: clearing.priority }
          ) do |token|
            plural_form = token.piece_type.pluralize
            send(plural_form) << token
            clearing.send(plural_form).delete(token)
            pieces_removed << token
          end
        end
        pieces_removed
      end

      def pre_move(move_action); end

      def pre_battle(battle); end

      def post_battle(battle); end
    end
  end
end
