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
      end

      def handle_faction_info_setup
        @completed_quests = Racoons::CompletedQuests.new
        @relationships = Racoons::Relationships.new([])
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

      def setup
        handle_character_select
        handle_forest_select
        handle_ruins
        handle_relationships
      end

      def damage_item(type)
        piece = undamaged_items.find { |item| item.item == type }
        piece.damage
      end

      def exhaust_item(type)
        piece = undamaged_items.find { |item| item.item == type && !item.exhausted? }
        piece.exhaust
      end

      def characters
        player.decks.characters
      end

      def handle_character_select
        player.choose(:r_char_sel, characters.deck, required: true) do |char|
          characters.remove_from_deck(char)
          char.class::STARTING_ITEMS.each { |item| make_item(item) }
          @character = char
          @character.f = self
        end
      end

      def quick_set_character(name)
        @character = Factions::Racoons::Characters::Character.for(name)
        @character.class::STARTING_ITEMS.each { |item| make_item(item) }
        @character.f = self
      end

      def handle_forest_select
        opts = board.forests.values
        player.choose(:r_forest_sel, opts, required: true) do |forest|
          board.place_meeple(meeples.pop, forest)
        end
      end

      def handle_ruins
        starting_items = %i[satchel boots hammer sword].shuffle

        board.ruins_clearings.each do |cl|
          item = starting_items.pop
          board.updater.add(cl, item)
          cl.items << item
        end
      end

      def handle_relationships
        others = players.except_player(player)
        @relationships = Racoons::Relationships.new(others)
      end

      def max_hit(clearing = current_location, ally: nil)
        num_swords = undamaged_items.count { |i| i.item == :sword }
        if ally
          clearing.meeples_of_type(ally.faction_symbol).count + num_swords
        else
          num_swords
        end
      end

      def take_damage(*, ally: nil)
        ally_sym = ally&.faction_symbol
        opts = if warriors_available_to_take_hit?(ally)
                 [ally_sym].concat(undamaged_items)
               else
                 undamaged_items
               end
        return if opts.empty?

        player.choose(:r_item_damage, opts, required: true) do |opt|
          opt == ally_sym ? ally.remove_meeple(current_location) : opt.damage
        end
      end

      def warriors_available_to_take_hit?(ally)
        return false unless ally

        current_location
          .meeples_of_type(ally.faction_symbol)
          .count
          .positive?
      end

      def birdsong
        super
        do_with_birdsong_options(:refresh_items) { refresh_items }
        do_with_birdsong_options(:slip) { slip }
      end

      def refresh_items
        num_to_refresh = 3 + (teas.count * 2)
        if num_to_refresh >= exhausted_items.count
          exhausted_items.each(&:refresh)
          return true
        end

        until num_to_refresh <= 0
          opts = refresh_item_options

          player.choose(
            :r_item_refresh,
            opts,
            required: true,
            info: { num: num_to_refresh },
            &:refresh
          )

          num_to_refresh -= 1
          true
        end
      end

      def refresh_item_options
        exhausted_items
      end

      def current_location
        board.clearings_with_meeples(faction_symbol).first
      end

      def other_factions_here(clearing = current_location)
        clearing.other_attackable_factions(faction_symbol)
      end

      def other_attackable_factions_here(clearing = current_location)
        other_attackable_factions(clearing)
      end

      def racoon_move(options, use_extra_boot: false)
        player.choose(:f_move_to_options, options) do |where_to|
          exhaust_extra_boot_if_needed(where_to) if use_extra_boot
          move_meeples(current_location, where_to, 1)
        end
      end

      # HACKY OH WELL LOL
      def move_with_allies(ally)
        other_fac = players.fetch_player(ally).faction
        opts = other_fac.clearing_move_options(current_location)

        player.choose(:f_move_to_options, opts) do |to|
          avail = current_location.meeples_of_type(other_fac.faction_symbol)
          max_choice = avail.count
          how_many_opts = [*1.upto(max_choice)]

          player.choose(:f_move_number, how_many_opts) do |num|
            Actions::Move
              .new(current_location, to, num, other_fac, lead_by: self)
              .()
            exhaust_extra_boot_if_needed(to)
            move_meeples(current_location, to, 1)
          end
        end
      end

      def exhaust_extra_boot_if_needed(clearing)
        exhaust_item(:boots) if location_hostile?(clearing)
      end

      def allied_move
        opts = available_allies(current_location)
        player.choose(:r_allied_move, opts, yield_anyway: true) do |ally|
          if ally == :none
            racoon_move(move_options, use_extra_boot: true)
          else
            move_with_allies(ally)
          end
        end
      end

      def slip
        racoon_move(slip_options)
      end

      def boots_move
        completed = if location_allied?(current_location)
                      allied_move
                    else
                      racoon_move(move_options, use_extra_boot: true)
                    end

        exhaust_item(:boots) if completed
      end

      def move_options
        current_location.adjacents.select do |adj|
          can_move_to?(current_location, adj)
        end
      end

      def slip_options
        current_location.all_adjacents
      end

      SIMPLE_SPECIALS = %i[steal day_labor].freeze

      def daylight
        super
        relationships.reset_turn_counters

        until daylight_options.empty?
          player.choose(
            :f_pick_action,
            daylight_options,
            yield_anyway: true,
            info: { actions: '' }
          ) do |action|
            # :nocov:
            case action
            when :move then boots_move
            when :battle then with_item(:sword) { battle }
            when :explore then with_item(:torch) { explore }
            when :strike then with_item(:crossbow) { strike }
            when :repair then with_item(:hammer) { repair }
            when :craft then hammer_craft
            when :aid then aid
            when :quest then quest
            when ->(n) { SIMPLE_SPECIALS.include?(n) }
              with_item(:torch) { use_special }
            when :hideout
              with_item(:torch) { use_special }
              return false
            when ->(n) { DAYLIGHT_OPTIONS.include?(n) } then do_daylight_option(action)
            when :none then return false
            end
            # :nocov:
          end
        end
      end

      def with_item(type)
        item = exhaust_item(type)
        return if yield

        item.refresh
      end

      # :nocov:
      def daylight_options
        [].tap do |options|
          options << :move if can_racoon_move?
          options << :battle if can_racoon_battle?
          options << :explore if can_explore?
          options << :aid if can_aid?
          options << :quest if can_quest?
          options << :strike if can_strike?
          options << :repair if can_repair?
          options << :craft if can_craft?
          options << special_name if can_special?
          add_daylight_options(options)
        end
      end
      # :nocov:

      def special_name
        character.class::POWER
      end

      def can_special?
        character&.can_special?
      end

      def use_special
        character.special
      end

      # Still a WIP for Hostile, but relationships shall come later.
      def can_move_to?(_clearing, adj)
        extra_boots_needed = location_hostile?(adj) ? 2 : 1
        boots_available = available_items.count { |i| i.item == :boots }
        boots_available >= extra_boots_needed
      end

      def location_hostile?(clearing)
        other_factions_here(clearing).any? { |o| relationships.hostile?(o) }
      end

      def available_allies(clearing)
        other_factions_here(clearing).select { |o| relationships.allied?(o) }
      end

      def location_allied?(clearing)
        !available_allies(clearing).empty?
      end

      def can_racoon_move?
        can_move? && available_items_include?(:boots)
      end

      def can_racoon_battle?
        can_battle? && available_items_include?(:sword)
      end

      def battle
        ally = pick_ally_for_battle
        opts = other_attackable_factions_here - [ally&.faction_symbol]
        player.choose(:f_who_to_battle, opts) do |fac_sym|
          faction_to_battle = players.fetch_player(fac_sym).faction
          Actions::Battle
            .new(current_location, self, faction_to_battle, ally: ally)
            .()
        end
      end

      def pick_ally_for_battle
        return if other_factions_here(current_location).count < 2

        opts = available_allies(current_location)
        return if opts.empty?

        player.choose(:r_allied_battle, opts) do |fac_sym|
          players.fetch_player(fac_sym).faction
        end
      end

      def can_explore?
        available_items_include?(:torch) &&
          current_location.includes_building?(:ruin)
      end

      def explore
        explored_item = current_location.explore
        board.updater.remove(current_location, explored_item)
        make_item(explored_item)
        player.add_to_history(
          :r_explore,
          clearing: current_location.priority,
          item: explored_item
        )
        gain_vps(1)
      end

      def can_strike?
        can_battle? && available_items_include?(:crossbow)
      end

      def strike
        opts = other_attackable_factions_here
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
        player.choose(
          :r_item_repair,
          damaged_items,
          info: { num: 1 },
          &:repair
        )
      end

      def quests
        player.decks.quests
      end

      def quests=(new_deck)
        player.decks.quests = new_deck
      end

      def active_quests
        quests.active_quests
      end

      def quest
        player.choose(:r_quest, quest_options) do |quest|
          pick_reward(quest) do
            quest.items.each { |type| exhaust_item(type) }
            quests.draw_new_card
            complete_quest(quest)
            quests.complete_quest(quest)

            player.add_to_history(
              :r_quest,
              suit: quest.suit,
              items: quest.items.join(' and ')
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
            gain_vps(points)
            value = "Gained #{points} victory points(s)"
          else
            draw_card(2)
            value = 'Drew 2 cards'
          end

          player.add_to_history(:r_quest_reward, value: value)
        end
      end

      def quest_options
        active_quests.select do |card|
          card.items.delete_elements_in(available_items.map(&:item)).empty? &&
            card.suit == current_location.suit
        end
      end

      def can_quest?
        !quest_options.empty?
      end

      def aid
        player.choose(:r_aid_faction, aid_options) do |fac_sym|
          other_player = players.fetch_player(fac_sym)
          other_faction = other_player.faction
          hand_opts = cards_in_hand_with_suit(current_location.suit)

          player.choose(:r_card_to_give, hand_opts) do |card|
            other_item_opts = other_faction.items + [:take_no_item]
            player.choose(:r_item_to_get, other_item_opts) do |item|
              player.choose(:r_item_exhaust, available_items) do |item_to_use|
                unless item == :take_no_item
                  other_faction.items.delete(item)
                  items << item
                end
                other_faction.hand << card
                hand.delete(card)

                gain_vps(2) if relationships.allied?(fac_sym)
                relationships.aid_once(fac_sym)
                gain_vps(relationships.vp_to_gain)

                exhaust_item(item_to_use.item)
                player.add_to_history(:r_aid_faction, other_faction: fac_sym)
              end
            end
          end
        end
      end

      def can_aid?
        !aid_options.empty? &&
          !available_items.empty? &&
          !cards_in_hand_with_suit(current_location.suit).empty?
      end

      def aid_options
        other_factions_here
      end

      def post_battle(battle)
        battle.removed_of_other_type(faction_symbol).each do |piece|
          if relationships.hostile?(piece.faction) && battle.attacker?(self) && battle.type == :battle
            gain_vps(1)
          end
          if piece.piece_type == :meeple && !battle.ally?(piece.faction)
            relationships.make_hostile(piece.faction)
          end
        end

        return unless battle.ally

        rem_meeples = battle.removed_of_type(battle.ally.faction_symbol).count
        rem_items = battle.removed_of_type(faction_symbol).count
        if rem_meeples > rem_items
          relationships.make_hostile(battle.ally.faction_symbol)
        end
      end

      def evening
        super
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

      def take_big_damage(*)
        3.times.collect { take_damage(current_location) }
      end

      def change_to_dominance(*)
        opts = players.options_to_coalition_with(faction_symbol)

        player.choose(:r_coalition, opts) do |fac_sym|
          self.victory_points = fac_sym
          player.add_to_history(:r_coalition, faction: fac_sym)
        end
      end
    end
  end
end
