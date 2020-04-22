# frozen_string_literal: true

require_relative '../cards/base'

module Root
  module Decks
    # This is the deck for crafting and ambushes and etc.
    # The idea here is just to leave room for exiles and partisans.
    class Starter < Base
      DECK_SIZE = 54

      # We're not currently interested in getting items done
      # Really just want to lay the foundation
      def generate_deck
        list_of_cards!
        deck.shuffle!
      end

      def list_of_cards!
        8.times { deck << Cards::Base.new(suit: :fox) }
        7.times { deck << Cards::Base.new(suit: :mouse) }
        9.times { deck << Cards::Base.new(suit: :bunny) }
        10.times { deck << Cards::Base.new(suit: :bird) }
        [
          { suit: :bird,  name: 'Arms Trader', craft: %i[fox fox], item: :sword, vp: 2 },
          { suit: :bird,  name: 'Birdy Bindle', craft: %i[mouse], item: :satchel, vp: 1 },
          { suit: :bird,  name: 'Crossbow', craft: %i[fox], item: :crossbow, vp: 1 },
          { suit: :bird,  name: 'Woodland Runners', craft: %i[bunny], item: :boots, vp: 1 },
          { suit: :fox,  name: 'Anvil', craft: %i[fox], item: :hammer, vp: 2 },
          { suit: :fox,  name: 'Foxfolk Steel', craft: %i[fox fox], item: :sword, vp: 2 },
          { suit: :fox,  name: 'Gently Used Knapsack', craft: %i[mouse], item: :satchel, vp: 1 },
          { suit: :fox,  name: 'Protection Racket', craft: %i[bunny bunny], item: :coin, vp: 3 },
          { suit: :fox,  name: 'Root Tea', craft: %i[mouse], item: :tea, vp: 2 },
          { suit: :fox,  name: 'Travel Gear', craft: %i[bunny], item: :boots, vp: 1 },
          { suit: :mouse,  name: 'Crossbow', craft: %i[fox], item: :crossbow, vp: 1 },
          { suit: :mouse,  name: 'Investments', craft: %i[bunny bunny], item: :coin, vp: 3 },
          { suit: :mouse,  name: 'Mouse-in-a-Sack', craft: %i[mouse], item: :satchel, vp: 1 },
          { suit: :mouse,  name: 'Root Tea', craft: %i[mouse], item: :tea, vp: 2 },
          { suit: :mouse,  name: 'Sword', craft: %i[fox fox], item: :sword, vp: 2 },
          { suit: :mouse,  name: 'Travel Gear', craft: %i[bunny], item: :boots, vp: 1 },
          { suit: :bunny,  name: 'A Visit to Friends', craft: %i[bunny], item: :boots, vp: 1 },
          { suit: :bunny,  name: 'Bake Sale', craft: %i[bunny bunny], item: :coin, vp: 3 },
          { suit: :bunny,  name: 'Root Tea', craft: %i[mouse], item: :tea, vp: 2 },
          { suit: :bunny, name: 'Smuggler\'s Trail', craft: %i[mouse], item: :Satchel, vp: 1 }
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
    end
  end
end

# :nocov:
# Suit  Name  Location  Craft Effects
# suit: :bird,  Ambush  Any  Defender deals 2 immediate hits unless Attacker plays Ambush, Discard
# suit: :bird,  Ambush  Any  Defender deals 2 immediate hits unless Attacker plays Ambush, Discard
# suit: :bird,  Armorers  F  In battle, may discard this to ignore all rolled hits taken
# suit: :bird,  Armorers  F  In battle, may discard this to ignore all rolled hits taken
# suit: :bird,  Brutal Tactics  FF  In battle as attacker, may deal an extra hit, but defender scores 1 VP.
# suit: :bird,  Brutal Tactics  FF  In battle as attacker, may deal an extra hit, but defender scores 1 VP.
# suit: :bird,  Dominance  NA  If at least 10VP, Play to rule Opposite Corners
# suit: :bird,  Royal Claim  ????  In Birdsong, discard to score 1VP per ruled clearing.
# suit: :bird,  Sappers  M  In battle as defender, discard to deal an extra hit.
# suit: :bird,  Sappers  M  In battle as defender, discard to deal an extra hit.
# suit: :fox,  Ambush  F  Defender deals 2 immediate hits unless Attacker plays Ambush, Discard
# suit: :fox,  Dominance  FFF  If at least 10VP, You win if you rule 3 fox clearings at start of your Birdsong
# suit: :fox,  Favor of the Foxes  FFF  Remove all enemy pieces in fox clearings, Discard
# suit: :fox,  Stand and Deliver!  MMM  In Birdsong, may take a random card from another play. That player scores 1 VP.
# suit: :fox,  Stand and Deliver!  MMM  In Birdsong, may take a random card from another play. That player scores 1 VP.
# suit: :fox,  Tax Collector  RFM  Once in Daylight, remove 1 of your warriors, draw 1
# suit: :fox,  Tax Collector  RFM  Once in Daylight, remove 1 of your warriors, draw 1
# suit: :fox,  Tax Collector  RFM  Once in Daylight, remove 1 of your warriors, draw 1
# suit: :mouse,  Ambush  M  Defender deals 2 immediate hits unless Attacker plays Ambush, Discard
# suit: :mouse,  Codebreakers  M  Once in Daylight, may look at another player's hand
# suit: :mouse,  Codebreakers  M  Once in Daylight, may look at another player's hand
# suit: :mouse,  Dominance  MMM  If at least 10VP, You win if you rule 3 mouse clearings at start of your Birdsong
# suit: :mouse,  Favor of the Mice  MMM  Remove all enemy pieces in mouse clearings, Discard
# suit: :mouse,  Scouting Party  MM  As attacker in battle, you are not affected by ambush cards.
# suit: :mouse,  Scouting Party  MM  As attacker in battle, you are not affected by ambush cards.
# suit: :rabbit,  Ambush  R  Defender deals 2 immediate hits unless Attacker plays Ambush, Discard
# suit: :rabbit,  Better Burrow Bank  RR  At start of Birdsong, you and another player draw a card.
# suit: :rabbit,  Better Burrow Bank  RR  At start of Birdsong, you and another player draw a card.
# suit: :rabbit,  Cobbler  RR  At start of Evening, may take a move
# suit: :rabbit, Cobbler  RR  At start of Evening, may take a move
# suit: :rabbit,  Command Warren  RR  At start of Daylight, may initiate a battle
# suit: :rabbit,  Command Warren  RR  At start of Daylight, may initiate a battle
# suit: :rabbit,  Dominance  RRR  If at least 10VP, You win if you rule 3 rabbit clearings at start of your Birdsong
# suit: :rabbit,  Favor of the Rabbits  RRR  Remove all enemy pieces in rabbit clearings, Discard
# :nocov:
