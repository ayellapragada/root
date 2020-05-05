# frozen_string_literal: true

require_relative './base'
require_relative '../factions/racoons/racoonable'

module Root
  module Factions
    # Handle racoon faction logic
    class Racoon < Base
      include Factions::Racoons::Racoonable

      SETUP_PRIORITY = 'D'

      attr_reader :character, :relationships, :completed_quests

      def faction_symbol
        :racoon
      end

      def handle_faction_token_setup
        @meeples = [Pieces::Meeple.new(:racoon)]
        @completed_quests = Racoons::CompletedQuests.new
      end

      def teas
        available_items.select { |item| item.of_type(:tea) }
      end

      def coins
        available_items.select { |item| item.of_type(:coin) }
      end

      def satchels
        available_items.select { |item| item.of_type(:satchel) }
      end

      def items_in_knapsack
        items - (teas + coins + satchels)
      end

      def available_items
        items
          .reject(&:exhausted?)
          .reject(&:damaged?)
      end

      def available_items_include?(type)
        available_items.any? { |item| item.item == type }
      end

      def undamaged_items
        items.reject(&:damaged?)
      end

      def damaged_items
        items.select(&:damaged?)
      end

      def exhausted_items
        items.select(&:exhausted?)
      end

      def formatted_character
        name = character&.name || 'none'
        name.capitalize
      end

      def formatted_relationships
        return 'No Relationships' unless @relationships

        "Affinity: #{@relationships.formatted_display}"
      end

      def board_title
        "#{formatted_character} | Nimble | Lone Wanderer\n#{teas.count} tea(s) | #{coins.count} coin(s) | #{satchels.count} satchel(s)\n#{formatted_relationships}"
      end

      def special_info(_show_private)
        {
          board: {
            title: board_title,
            rows: [formatted_items]
          }
        }
      end

      def formatted_items
        return ['No Items'] if items.empty?

        [
          word_wrap_string(format_items(items_in_knapsack))
        ]
      end

      def format_items(items_to_format)
        items_to_format
          .sort_by { |item| [item.damaged? ? 1 : 0, item.exhausted? ? 1 : 0, item.item] }
          .map(&:format_with_status)
          .join(', ')
      end

      def setup(players:, characters:)
        handle_character_select(characters)
        handle_forest_select
        handle_ruins
        handle_relationships(players)
      end

      def damage_item(type)
        piece = undamaged_items.find { |item| item.item == type }
        piece.damage
      end

      def exhaust_item(type)
        piece = undamaged_items.find { |item| item.item == type && !item.exhausted? }
        piece.exhaust
      end

      def handle_character_select(characters)
        player.choose(:r_char_sel, characters.deck, required: true) do |char|
          characters.remove_from_deck(char)
          char.starting_items.each { |item| make_item(item) }
          @character = char
        end
      end

      def quick_set_character(name)
        @character = Factions::Racoons::Character.new(name: name)
      end

      def handle_forest_select
        opts = board.forests.values
        player.choose(:r_forest_sel, opts, required: true) do |forest|
          board.place_meeple(meeples.pop, forest)
        end
      end

      def handle_ruins
        starting_items = %i[satchel boots hammer sword].shuffle
        board.ruins.each do |ruin|
          ruin.items << starting_items.pop
        end
      end

      def handle_relationships(players)
        others = players.except_player(player)
        @relationships = Racoons::Relationships.new(others)
      end

      def max_hit(*)
        undamaged_items.count { |i| i.item == :sword }
      end

      def take_damage(*)
        return [] if undamaged_items.empty?

        player.choose(:r_item_damage, undamaged_items, required: true, &:damage)
      end

      def take_turn(players:, quests:)
        super
        birdsong(players)
        daylight(players, quests)
        evening
      end

      def birdsong(players)
        refresh_items
        slip(players)
      end

      def refresh_items
        num_to_refresh = 3 + (teas.count * 2)
        if num_to_refresh >= exhausted_items.count
          exhausted_items.each(&:refresh)
        else
          num_to_refresh.times do
            opts = refresh_item_options
            player.choose(:r_item_refresh, opts, required: true, &:refresh)
          end
        end
      end

      def refresh_item_options
        exhausted_items
      end

      def current_location
        board.clearings_with_meeples(faction_symbol).first
      end

      def racoon_move(players, options, use_extra_boot: false)
        player.choose(:f_move_to_options, options) do |where_to|
          # exhaust_item(:boots) if location.hostile? && use_extra_boot
          move_meeples(current_location, where_to, 1, players)
        end
      end

      def slip(players)
        racoon_move(players, slip_options)
      end

      def boots_move(players)
        racoon_move(players, current_location.adjacents, use_extra_boot: true)
      end

      def slip_options
        current_location.all_adjacents
      end

      def daylight(players, quests)
        until daylight_options(active_quests: quests.active_quests).empty?
          player.choose(
            :f_pick_action,
            daylight_options(active_quests: quests.active_quests),
            yield_anyway: true,
            info: { actions: '' }
          ) do |action|
            # :nocov:
            case action
            when :move then with_item(:boots) { boots_move(players) }
            when :battle then with_item(:sword) { battle_in_clearing(current_location, players) }
            when :explore then with_item(:torch) { explore }
            when :strike then with_item(:crossbow) { strike(players) }
            when :repair then with_item(:hammer) { repair }
            when :craft then hammer_craft
            # when :aid then aid
            when :quest then quest(quests)
            when :none then return false
            end
            # :nocov:
          end
        end
      end

      def with_item(type)
        # IF TYPE == nil then select an item type (for aid)
        exhaust_item(type) if yield
      end

      # :nocov:
      def daylight_options(active_quests: [])
        [].tap do |options|
          options << :move if can_move?
          options << :battle if can_racoon_battle?
          options << :explore if can_explore?
          # options << :aid if can_aid?
          options << :quest if can_quest?(active_quests)
          options << :strike if can_strike?
          options << :repair if can_repair?
          options << :craft if can_craft?
        end
      end
      # :nocov:

      # Still a WIP for Hostile, but relationships shall come later.
      def can_move_to?(_clearing, _adj)
        available_items_include?(:boots)
      end

      def can_racoon_battle?
        can_battle? && available_items_include?(:sword)
      end

      def can_explore?
        available_items_include?(:torch) &&
          current_location.includes_building?(:ruin)
      end

      def explore
        explored_item = current_location.explore
        make_item(explored_item)
        player.add_to_history(
          :r_explore,
          clearing: current_location.priority,
          item: explored_item
        )
        self.victory_points += 1
      end

      def can_strike?
        can_battle? && available_items_include?(:crossbow)
      end

      def strike(players)
        opts = current_location.other_attackable_factions(faction_symbol)
        player.choose(:f_who_to_battle, opts) do |fac_sym|
          faction_to_battle = players.fetch_player(fac_sym).faction
          Actions::Battle.new(current_location, self, faction_to_battle).strike
        end
      end

      def suits_to_craft_with
        num_hammers = available_items.count { |item| item.item == :hammer }
        Array.new(num_hammers) { current_location.suit }
      end

      def hammer_craft
        craft_items { |item| item.craft.count.times { exhaust_item(:hammer) } }
      end

      def can_repair?
        !damaged_items.empty? && available_items_include?(:hammer)
      end

      def repair
        player.choose(:r_item_repair, damaged_items, &:repair)
      end

      def quest(quests)
        player.choose(:r_quest, quest_options(quests.active_quests)) do |quest|
          pick_reward(quest) do
            quest.items.each { |type| exhaust_item(type) }
            quests.draw_new_card
            complete_quest(quest)
            quests.complete_quest(quest)

            player.add_to_history(
              :r_quest,
              suit: quest.suit,
              items: quest.items.join(', ')
            )
          end
        end
      end

      def complete_quest(quest)
        completed_quests.complete_quest(quest)
      end

      def completed_quests_of(suit)
        completed_quests[suit]
      end

      def pick_reward(quest)
        opts = %i[get_victory_points draw_cards]
        # at this point we technically have not completed the quest
        # we only want to actually complete it ONCE they've picked
        # a reward and confirmed
        points = completed_quests_of(quest.suit).count + 1

        player.choose(:r_quest_reward, opts, info: { vps: points }) do |reward|
          yield(reward, points) if block_given?

          if reward == :get_victory_points
            self.victory_points += points
            value = "Gained #{points} victory points(s)"
          else
            2.times { draw_card }
            value = 'Drew 2 cards'
          end

          player.add_to_history(:r_quest_reward, value: value)
        end
      end

      def quest_options(active_quests)
        active_quests.select do |card|
          card.items.delete_elements_in(available_items.map(&:item)).empty? &&
            card.suit == current_location.suit
        end
      end

      def can_quest?(active_quests)
        !quest_options(active_quests).empty?
      end

      def evening
        evening_rest
        draw_cards
        discard_items
      end

      def draw_bonuses
        coins.count
      end

      def evening_rest
        completely_fix_all_items if can_evening_rest?
      end

      def completely_fix_all_items
        items.each do |item|
          item.repair
          item.refresh
        end
      end

      def discard_items
        until items_in_knapsack.count <= knapsack_capacity
          opts = items_in_knapsack
          player.choose(:r_item_discard, opts, required: true) do |item|
            items.delete(item)
          end
        end
      end

      def can_evening_rest?
        current_location.forest?
      end

      def knapsack_capacity
        6 + (satchels.count * 2)
      end
    end
  end
end
