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
      end

      def add_base_cards
        5.times { deck << Cards::Base.new(suit: :fox) }
        4.times { deck << Cards::Base.new(suit: :mouse) }
        6.times { deck << Cards::Base.new(suit: :rabbit) }
        7.times { deck << Cards::Base.new(suit: :bird) }
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
    end
  end
end

# rubocop:disable all
# :nocov:

# Battle
# :bird,  Armorers  F  In battle, may discard this to ignore all rolled hits taken
# :bird,  Armorers  F  In battle, may discard this to ignore all rolled hits taken
# :bird,  Sappers  M  In battle as defender, discard to deal an extra hit.
# :bird,  Sappers  M  In battle as defender, discard to deal an extra hit.

# Improvements
# :mouse,  Scouting Party  MM  As attacker in battle, you are not affected by ambush cards.
# :mouse,  Scouting Party  MM  As attacker in battle, you are not affected by ambush cards.
# :bird,  Brutal Tactics  FF  In battle as attacker, may deal an extra hit, but defender scores 1 VP.
# :bird,  Brutal Tactics  FF  In battle as attacker, may deal an extra hit, but defender scores 1 VP.

# Birdsong
# :rabbit,  Better Burrow Bank  RR  At start of Birdsong, you and another player draw a card.
# :rabbit,  Better Burrow Bank  RR  At start of Birdsong, you and another player draw a card.
# :bird,  Royal Claim  ????  In Birdsong, discard to score 1VP per ruled clearing.
# :fox,  Stand and Deliver!  MMM  In Birdsong, may take a random card from another play. That player scores 1 VP.
# :fox,  Stand and Deliver!  MMM  In Birdsong, may take a random card from another play. That player scores 1 VP.

# Daylight
# :rabbit,  Command Warren  RR  At start of Daylight, may initiate a battle
# :rabbit,  Command Warren  RR  At start of Daylight, may initiate a battle
# :fox,  Tax Collector  RFM  Once in Daylight, remove 1 of your warriors, draw 1
# :fox,  Tax Collector  RFM  Once in Daylight, remove 1 of your warriors, draw 1
# :fox,  Tax Collector  RFM  Once in Daylight, remove 1 of your warriors, draw 1
# :mouse,  Codebreakers  M  Once in Daylight, may look at another player's hand
# :mouse,  Codebreakers  M  Once in Daylight, may look at another player's hand

# Evening
# :rabbit,  Cobbler  RR  At start of Evening, may take a move
# :rabbit, Cobbler  RR  At start of Evening, may take a move

# :nocov:
# rubocop:enable all
