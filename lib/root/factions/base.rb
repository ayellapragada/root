# frozen_string_literal: true

require_relative '../core_extensions/symbol/pluralize'
require_relative '../core_extensions/array/better_deletes'

module Root
  module Factions
    # Interface for basic faction logic
    class Base
      Symbol.include CoreExtensions::Symbol::Pluralize
      Array.include CoreExtensions::Array::BetterDeletes

      DAYLIGHT_OPTIONS = %i[take_dominance play_dominance].freeze

      SETUP_PRIORITY = 'ZZZ'

      HISTORY_EXCLUSION = %i[wood].freeze
      POINTS_FOR_WIN = 30

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

      attr_reader :hand, :player, :meeples, :buildings, :tokens, :items,
                  :improvements
      attr_writer :board

      def initialize(player)
        @player = player
        @hand = []
        @items = []
        @improvements = []
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

      def dominance
        deck.dominance
      end

      def players
        player.players
      end

      def gain_vps(value)
        return if win_via_dominance?

        self.victory_points += value
      end

      def victory_points=(value)
        @victory_points = value

        return if win_via_dominance?
        return if @victory_points < POINTS_FOR_WIN

        raise Errors::WinConditionReached.new(self, :vps)
      end

      def win_via_dominance?
        !@victory_points.is_a?(Numeric)
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

      def take_turn
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
      def word_wrap_string(string, _el = ', ')
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

          return false unless player.choose(key, options) do |choice|
            yield(choice)
          end
        end
      end

      def craft_with_specific_timing
        until craft_with_specific_timing_options.empty?
          player.choose(
            :f_pick_action,
            craft_with_specific_timing_options,
            yield_anyway: true,
            info: { actions: '' }
          ) do |action|
            # :nocov:
            case action
            when :craft then craft_items
            when ->(n) { DAYLIGHT_OPTIONS.include?(n) } then do_daylight_option(action)
            when :none then return false
            end
            # :nocov:
          end
        end
      end

      def craft_with_specific_timing_options
        [].tap do |options|
          options << :craft if can_craft?
          add_daylight_options(options)
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
        choice.faction_craft(self)
      end

      def play_card(choice)
        choice.faction_play(self)
      end

      def make_item(type)
        @items << Pieces::Item.new(type)
      end

      def handle_item_vp(item)
        item.vp
      end

      def craftable_items
        @crafted_suits ||= []
        usable_suits = suits_to_craft_with.delete_elements_in(@crafted_suits)
        return [] if usable_suits.empty?

        craftable_cards_in_hand(usable_suits)
      end

      def craftable_cards_in_hand(suits)
        hand.select do |card|
          card.craftable?(board) &&
            card.craft.delete_elements_in(suits).empty? &&
            not_already_crafted_improvement?(card)
        end
      end

      def not_already_crafted_improvement?(card)
        return true unless card.improvement?

        !improvements_include?(card.type)
      end

      def can_craft?
        !craftable_items.empty?
      end

      def make_move(required: false)
        player.choose(
          :f_move_from_options,
          move_options,
          required: required
        ) do |cl|
          move(cl)
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

      def move(clearing)
        opts = clearing_move_options(clearing)

        player.choose(:f_move_to_options, opts) do |where_to|
          max_choice = clearing.meeples_of_type(faction_symbol).count
          how_many_opts = [*1.upto(max_choice)]

          player.choose(:f_move_number, how_many_opts) do |how_many|
            move_meeples(clearing, where_to, how_many)
          end
        end
      end

      def move_meeples(from, to, num)
        Actions::Move.new(from, to, num, self).()
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

      def battle
        player.choose(:f_battle_options, battle_options) do |cl|
          battle_in_clearing(cl)
        end
      end

      def battle_in_clearing(clearing)
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

      # OH MY GOD THE HAND REFACTOR MIGHT JUST BE THIS
      # :PRAY: THIS LEGIT MIGHT JUST NEED A REAVEALED? CHECK AND WE'RE GOOD!
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

      def take_damage(clearing, *)
        cl_meeples = clearing.meeples_of_type(faction_symbol)
        cardboard_pieces =
          (clearing.buildings_of_faction(faction_symbol) +
           clearing.tokens_of_faction(faction_symbol))
        if !cl_meeples.empty?
          piece = remove_meeple(clearing)
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
            piece = token
          end
        end
        piece
      end

      def remove_meeple(clearing)
        cl_meeples = clearing.meeples_of_type(faction_symbol)
        piece = cl_meeples.first
        clearing.meeples.delete(piece)
        meeples << piece
        piece
      end

      def do_big_damage(clearing)
        others = clearing.other_attackable_factions(faction_symbol)
        pieces = []
        others.each do |sym|
          pieces << players.fetch_player(sym).faction.take_big_damage(clearing)
        end

        pieces.flatten.each do |piece|
          type = piece.piece_type
          gain_vps(1) if %i[building token].include?(type)
        end
      end

      def take_big_damage(clearing)
        clearing.all_pieces_of_type(faction_symbol).map do |piece|
          type = piece.piece_type
          plural_form = type.pluralize
          send(plural_form) << piece
          clearing.send(plural_form).delete(piece)
          piece
        end
      end

      def birdsong
        check_for_dominance if win_via_dominance?
        use_improvement(:better_burrow_bank)
      end

      def daylight
        use_improvement(:command_warren)
      end

      def check_for_dominance
        Actions::Dominance.new(self).check
      end

      def change_to_dominance(suit)
        self.victory_points = suit unless win_via_dominance?
      end

      def do_daylight_option(action)
        send(action)
      end

      # code breakers, tax collectors
      # improvements.each { |i| options << i.name if i.can_use?(fac) }
      # :nocov:
      def add_daylight_options(options)
        options << :take_dominance if take_dominance?
        options << :play_dominance if play_dominance?
        options
      end
      # :nocov:

      def take_dominance?
        !take_dominance_opts.empty?
      end

      def take_dominance_opts
        dominance.select do |suit, data|
          next false unless data[:card]

          !cards_in_hand_with_suit(suit).empty?
        end.map { |arr| arr[1][:card] }
      end

      def take_dominance
        player.choose(:f_take_dominance, take_dominance_opts) do |card|
          suit = card.suit
          discard_card_with_suit(suit, required: false) do
            hand << deck.dominance_for(suit)
            deck.change_dominance(suit, '-')
            player.add_to_history(:f_take_dominance, suit: suit)
          end
        end
      end

      def play_dominance?
        return false if win_via_dominance?

        victory_points >= 10 && !play_dominance_opts.empty?
      end

      def play_dominance_opts
        hand.select(&:dominance?)
      end

      def play_dominance
        player.choose(:f_dominance, play_dominance_opts) do |card|
          play_card(card)
          player.add_to_history(:f_dominance, suit: card.suit)
        end
      end

      def ambush_opts(clearing)
        cards_in_hand_with_suit(clearing.suit).select(&:ambush?)
      end

      def available_improvements
        improvements.reject(&:exhausted)
      end

      def improvements_include?(type)
        available_improvements.map(&:type).include?(type)
      end

      def use_improvement(type)
        return unless improvements_include?(type)

        improvements_options(type).first.faction_use(self)
      end

      def improvements_options(type)
        available_improvements.select { |imp| imp.type == type }
      end

      def discard_improvement(card)
        improvements.delete(card)
        deck.discard_card(card)
      end

      def other_factions
        players.except_player(player).map(&:faction)
      end

      def pre_move(move_action); end

      def pre_battle(battle); end

      def post_battle(battle); end
    end
  end
end
