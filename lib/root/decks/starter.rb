# frozen_string_literal: true

require_relative './shared'
require_relative '../cards/base'

module Root
  module Decks
    # This is the deck for crafting and ambushes and etc.
    class Starter < Shared
      DECK_SIZE = 54

      def list_of_cards!
        add_base_cards
        add_item_cards
        add_favor_cards
        add_dominance_cards
        add_ambush_cards
        add_improvements
      end

      def add_base_cards
        5.times { deck << Cards::Base.new(suit: :fox) }
        2.times { deck << Cards::Base.new(suit: :mouse) }
        1.times { deck << Cards::Base.new(suit: :bird) }
      end

      # rubocop:disable all
      def add_item_cards
        [
          { suit: :bird,  name: 'Arms Trader', craft: %i[fox fox], item: :sword, vp: 2 },
          { suit: :bird,  name: 'Birdy Bindle', craft: %i[mouse], item: :satchel, vp: 1 },
          { suit: :bird,  name: 'Crossbow', craft: %i[fox], item: :crossbow, vp: 1 },
          { suit: :bird,  name: 'Woodland Runners', craft: %i[rabbit], item: :boots, vp: 1 },

          { suit: :fox,  name: 'Anvil', craft: %i[fox], item: :hammer, vp: 2 },
          { suit: :fox,  name: 'Foxfolk Steel', craft: %i[fox fox], item: :sword, vp: 2 },
          { suit: :fox,  name: 'Gently Used Knapsack', craft: %i[mouse], item: :satchel, vp: 1 },
          { suit: :fox,  name: 'Protection Racket', craft: %i[rabbit rabbit], item: :coin, vp: 3 },
          { suit: :fox,  name: 'Root Tea', craft: %i[mouse], item: :tea, vp: 2 },
          { suit: :fox,  name: 'Travel Gear', craft: %i[rabbit], item: :boots, vp: 1 },

          { suit: :mouse,  name: 'Crossbow', craft: %i[fox], item: :crossbow, vp: 1 },
          { suit: :mouse,  name: 'Investments', craft: %i[rabbit rabbit], item: :coin, vp: 3 },
          { suit: :mouse,  name: 'Mouse-in-a-Sack', craft: %i[mouse], item: :satchel, vp: 1 },
          { suit: :mouse,  name: 'Root Tea', craft: %i[mouse], item: :tea, vp: 2 },
          { suit: :mouse,  name: 'Sword', craft: %i[fox fox], item: :sword, vp: 2 },
          { suit: :mouse,  name: 'Travel Gear', craft: %i[rabbit], item: :boots, vp: 1 },

          { suit: :rabbit,  name: 'A Visit to Friends', craft: %i[rabbit], item: :boots, vp: 1 },
          { suit: :rabbit,  name: 'Bake Sale', craft: %i[rabbit rabbit], item: :coin, vp: 3 },
          { suit: :rabbit,  name: 'Root Tea', craft: %i[mouse], item: :tea, vp: 2 },
          { suit: :rabbit, name: 'Smuggler\'s Trail', craft: %i[mouse], item: :Satchel, vp: 1 }
        ].each do |row|
          deck << Cards::Item.new(
            suit: row[:suit],
            name: row[:name],
            craft: row[:craft],
            item: row[:item],
            vp: row[:vp]
          )
        end
      end
      # rubocop:enable all

      def add_favor_cards
        %i[fox mouse rabbit].each do |suit|
          deck << Cards::Favor.new(suit: suit)
        end
      end

      def add_dominance_cards
        %i[bird fox mouse rabbit].each do |suit|
          deck << Cards::Dominance.new(suit: suit)
        end
      end

      def add_ambush_cards
        %i[bird bird fox mouse rabbit].each do |suit|
          deck << Cards::Ambush.new(suit: suit)
        end
      end

      def add_improvements
        2.times { deck << Cards::Improvements::Armorers.new }
        2.times { deck << Cards::Improvements::Sappers.new }
        2.times { deck << Cards::Improvements::ScoutingParty.new }
        2.times { deck << Cards::Improvements::BrutalTactics.new }
        2.times { deck << Cards::Improvements::BetterBurrowBank.new }
        2.times { deck << Cards::Improvements::CommandWarren.new }
        2.times { deck << Cards::Improvements::Cobbler.new }
      end
    end
  end
end

# rubocop:disable all
# :nocov:

# Improvements
# Birdsong
# :fox,  Stand and Deliver!  MMM  In Birdsong, may take a random card from another play. That player scores 1 VP.
# :fox,  Stand and Deliver!  MMM  In Birdsong, may take a random card from another play. That player scores 1 VP.

# Daylight
# :fox,  Tax Collector  RFM  Once in Daylight, remove 1 of your warriors, draw 1
# :fox,  Tax Collector  RFM  Once in Daylight, remove 1 of your warriors, draw 1
# :fox,  Tax Collector  RFM  Once in Daylight, remove 1 of your warriors, draw 1
# :mouse,  Codebreakers  M  Once in Daylight, may look at another player's hand
# :mouse,  Codebreakers  M  Once in Daylight, may look at another player's hand

# this might be doable with the same thing as dominance. whatever. not worth stressing about tbh
# :bird,  Royal Claim  ????  In Birdsong, discard to score 1VP per ruled clearing.
# :nocov:
# rubocop:enable all
