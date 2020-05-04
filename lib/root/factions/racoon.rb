# frozen_string_literal: true

require_relative './base'
require_relative '../factions/racoons/racoonable'

module Root
  module Factions
    # Handle racoon faction logic
    class Racoon < Base
      include Factions::Racoons::Racoonable

      SETUP_PRIORITY = 'D'

      attr_reader :character, :relationships

      def faction_symbol
        :racoon
      end

      def handle_faction_token_setup
        @meeples = [Pieces::Meeple.new(:racoon)]
      end

      def teas
        refreshed_and_undamaged_items.select { |item| item.of_type(:tea) }
      end

      def coins
        refreshed_and_undamaged_items.select { |item| item.of_type(:coin) }
      end

      def satchels
        refreshed_and_undamaged_items.select { |item| item.of_type(:satchel) }
      end

      def items_in_knapsack
        items - (teas + coins + satchels)
      end

      def refreshed_and_undamaged_items
        items
          .reject(&:exhausted?)
          .reject(&:damaged?)
      end

      def available_items_include?(type)
        refreshed_and_undamaged_items.any? { |item| item.item == type }
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
        starting_items = %i[bag boots hammer sword].shuffle
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

      def take_turn(players:, active_quests:)
        birdsong(players)
        daylight(players, active_quests)
        # evening
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

      def daylight(players, active_quests)
        until daylight_options(active_quests: active_quests).empty?
          player.choose(
            :f_pick_action,
            daylight_options(active_quests: active_quests),
            yield_anyway: true,
            info: { actions: '' }
          ) do |action|
            # :nocov:
            case action
            when :move then with_item(:boots) { boots_move(players) }
            when :battle then with_item(:sword) { battle(players) }
            when :none then return false
            end
            # :nocov:
          end
        end
      end

      def with_item(type)
        exhaust_item(type) if yield
      end

      # :nocov:
      # TEMPORARY
      # def daylight_options(active_quests: [])
      def daylight_options(*)
        [].tap do |options|
          options << :move if can_move?
          options << :battle if can_battle?
          # options << :explore if can_explore?
          # options << :aid if can_aid?
          # options << :quest if can_quest?
          # options << :strike if can_strike?
          # options << :repair if can_repair?
          # options << :craft if can_craft?
        end
      end
      # :nocov:

      # Still a WIP for Hostile, but relationships shall come later.
      def can_move_to?(_clearing, _adj)
        available_items_include?(:boots)
      end

      def can_battle?
        super && available_items_include?(:sword)
      end
    end
  end
end
